const admin = require('firebase-admin');
const Device = require('../models/Device');
const Reading = require('../models/Reading');
const Alert = require('../models/Alert');

const PUSH_COOLDOWN_MS = 15 * 60 * 1000; // 15 Minutes

exports.ingestTelemetry = async (req, res) => {
  try {
    // Graceful fallback for missing flags
    const { 
      deviceId, 
      status, 
      flags = { hardwareFault: false, isCritical: false }, 
      metrics 
    } = req.body;

    // 1. Persist Reading
    const newReading = await Reading.create({ deviceId, status, flags, metrics, timestamp: new Date() });

    // 2. Fetch Device & Registered Token
    const device = await Device.findOne({ deviceId });
    if (!device || !device.fcmToken) {
      return res.status(200).json({ success: true, warning: 'No FCM token associated with device' });
    }

    // 3. Determine Last Alert State
    const lastAlert = await Alert.findOne({ deviceId, channel: 'push' }).sort({ timestamp: -1 });

    const previousStatus = device.lastStatus || 'SAFE';
    const previousFault = device.lastHardwareFault || false;

    const statusChanged = status !== previousStatus;
    const faultToggledOn = flags.hardwareFault && !previousFault;
    const isRecovered = previousStatus !== 'SAFE' && status === 'SAFE';

    const cooldownElapsed = !lastAlert || (Date.now() - new Date(lastAlert.timestamp).getTime() >= PUSH_COOLDOWN_MS);

    let shouldNotify = false;
    let title = '';
    let body = '';

    // Rule Evaluation
    if (faultToggledOn) {
      shouldNotify = true;
      title = '⚠️ Hardware Sensor Fault';
      body = `Turbidity sensor signal loss detected on node ${deviceId}. Inspect hardware connection.`;
    } else if (statusChanged && status === 'UNSAFE') {
      shouldNotify = true;
      title = '🚨 CRITICAL: Water Unsafe!';
      body = `Water parameters breached emergency thresholds (pH: ${metrics.ph}, TDS: ${metrics.tds_ppm} PPM, Turb: ${metrics.turbidity_ntu} NTU).`;
    } else if (statusChanged && (status === 'CAUTION' || status === 'LIMITED USE')) {
      shouldNotify = true;
      title = `⚠️ Water Quality Warning: ${status}`;
      body = `Water condition shifted to ${status}. Check app for parameter details.`;
    } else if (isRecovered) {
      shouldNotify = true;
      title = '✅ Water Quality Recovered';
      body = `Water parameters have returned to SAFE levels.`;
    } else if (status !== 'SAFE' && cooldownElapsed) {
      // Sustained Hazard Reminder
      shouldNotify = true;
      title = `📢 Reminder: Water is still ${status}`;
      body = `Sustained excursion active on ${deviceId}. Current pH: ${metrics.ph}, TDS: ${metrics.tds_ppm}.`;
    }

    // 4. Dispatch FCM Notification
    if (shouldNotify) {
      const message = {
        token: device.fcmToken,
        notification: { title, body },
        data: {
          deviceId,
          status,
          isCritical: String(flags.isCritical),
          hardwareFault: String(flags.hardwareFault),
        },
      };

      try {
        await admin.messaging().send(message);
        console.log(`[FCM Push Sent] Status: ${status} to device: ${deviceId}`);
        
        // Log Alert to MongoDB
        await Alert.create({ 
          deviceId, 
          channel: 'push', 
          status, 
          timestamp: new Date(),
          message: body 
        });
      } catch (fcmError) {
        console.error('❌ FCM Dispatch Error:', fcmError);
      }
    }

    // 5. Update Device State Flags
    device.lastStatus = status;
    device.lastHardwareFault = flags.hardwareFault;
    await device.save();

    return res.status(200).json({ success: true, message: 'Telemetry processed successfully' });
  } catch (error) {
    console.error('❌ Telemetry Processing Error:', error);
    return res.status(500).json({ error: error.message });
  }
};
