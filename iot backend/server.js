const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json()); // Parses incoming JSON payloads

const NotificationService = require('./services/notificationService');
const Telemetry = require('./models/telemetry');
const Alert = require('./models/alert');
const DeviceToken = require('./models/deviceToken');

// ==========================================================
// CONNECT TO MONGO REPOSITORY
// ==========================================================
mongoose.connect(process.env.MONGO_URI)
    .then(async () => {
      console.log('Successfully connected to MongoDB Atlas.');
      await NotificationService.initializeNotificationService();
    })
    .catch(err => console.error('Database connection error:', err));

// ==========================================================
// HTTP POST: ESP32 INGRESS GATEWAY
// ==========================================================
app.post('/api/telemetry', async (req, res) => {
    try {
        const { deviceId, metrics, status } = req.body;
        
        const newRecord = new Telemetry({
            deviceId,
            metrics,
            status
        });
        
        const savedRecord = await newRecord.save();
        console.log(`[Data Ingress] Telemetry saved from ${deviceId} | Status: ${status}`);

        // Evaluate alert transitions after successful save
        await NotificationService.evaluateTelemetryRecord(savedRecord);

        return res.status(201).json({ success: true, message: "Telemetry persisted successfully." });
    } catch (error) {
        console.error('Error handling hardware ingest:', error);
        return res.status(500).json({ success: false, error: 'Internal Server Space Error' });
    }
});

// ==========================================================
// HTTP GET: MOBILE CLIENT DATA FETCH
// ==========================================================
app.get('/api/telemetry/latest/:deviceId', async (req, res) => {
    try {
        const latestData = await Telemetry.findOne({ deviceId: req.params.deviceId })
                                           .sort({ timestamp: -1 });
        
        if (!latestData) {
            return res.status(404).json({ success: false, message: "No logs found for this device ID." });
        }
        
        return res.status(200).json({ success: true, data: latestData });
    } catch (error) {
        return res.status(500).json({ success: false, error: error.message });
    }
});

// ==========================================================
// HTTP POST: REGISTER CLIENT PUSH TOKEN
// ==========================================================
app.post('/api/register-token', async (req, res) => {
  try {
    const { deviceId, token, platform } = req.body;
    await NotificationService.registerDeviceToken(deviceId, token, platform);
    return res.status(200).json({ success: true, message: 'Token registered successfully.' });
  } catch (error) {
    console.error('Token registration failed:', error);
    return res.status(500).json({ success: false, error: error.message });
  }
});

// ==========================================================
// HTTP GET: ALERT HISTORY
// ==========================================================
app.get('/api/alerts', async (req, res) => {
  try {
    const alerts = await NotificationService.getAlerts();
    return res.status(200).json({ success: true, data: alerts });
  } catch (error) {
    console.error('Error retrieving alerts:', error);
    return res.status(500).json({ success: false, error: error.message });
  }
});

// ==========================================================
// HTTP POST: MARK ALERT READ
// ==========================================================
app.post('/api/alerts/:id/read', async (req, res) => {
  try {
    const { id } = req.params;
    await NotificationService.markAlertRead(id);
    return res.status(200).json({ success: true, message: 'Alert marked as read.' });
  } catch (error) {
    console.error('Error marking alert read:', error);
    return res.status(500).json({ success: false, error: error.message });
  }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Backend service processing on port ${PORT}`));