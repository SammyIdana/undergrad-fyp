const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json()); // Parses incoming JSON payloads

const admin = require('firebase-admin');
const serviceAccount = require('./firebase-service-account.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const telemetryController = require('./controllers/telemetryController');
const Reading = require('./models/Reading');
const Alert = require('./models/Alert');
const Device = require('./models/Device');

// ==========================================================
// CONNECT TO MONGO REPOSITORY
// ==========================================================
mongoose.connect(process.env.MONGO_URI)
    .then(async () => {
      console.log('Successfully connected to MongoDB Atlas.');
    })
    .catch(err => console.error('Database connection error:', err));

// ==========================================================
// HTTP POST: ESP32 INGRESS GATEWAY
// ==========================================================
app.post('/api/telemetry', telemetryController.ingestTelemetry);

// ==========================================================
// HTTP GET: MOBILE CLIENT DATA FETCH
// ==========================================================
app.get('/api/telemetry/latest/:deviceId', async (req, res) => {
    try {
        const latestData = await Reading.findOne({ deviceId: req.params.deviceId })
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
    if (!token) return res.status(400).json({ success: false, error: 'Missing token' });
    await Device.findOneAndUpdate(
      { deviceId },
      { deviceId, fcmToken: token, platform, createdAt: new Date() },
      { upsert: true, new: true }
    );
    console.log(`Registered FCM token for device ${deviceId}`);
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
    const alerts = await Alert.find().sort({ timestamp: -1 }).limit(50).lean();
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
    await Alert.findByIdAndUpdate(id, { read: true });
    return res.status(200).json({ success: true, message: 'Alert marked as read.' });
  } catch (error) {
    console.error('Error marking alert read:', error);
    return res.status(500).json({ success: false, error: error.message });
  }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Backend service processing on port ${PORT}`));