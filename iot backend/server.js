const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json()); // Parses incoming JSON payloads

// ==========================================================
// MONGOOSE DATA SCHEMA & MODEL
// ==========================================================
const TelemetrySchema = new mongoose.Schema({
    deviceId: { type: String, required: true, index: true },
    metrics: {
        temperature: { type: Number, required: true },
        tds_ppm: { type: Number, required: true },
        turbidity_ntu: { type: Number, required: true },
        ph: { type: Number, required: true }
    },
    status: { type: String, required: true },
    timestamp: { type: Date, default: Date.now, index: -1 } // Fast descending index for mobile app
});

const Telemetry = mongoose.model('Telemetry', TelemetrySchema);

// ==========================================================
// CONNECT TO MONGO REPOSITORY
// ==========================================================
mongoose.connect(process.env.MONGO_URI)
    .then(() => console.log('Successfully connected to MongoDB Atlas.'))
    .catch(err => console.error('Database connection error:', err));

// ==========================================================
// HTTP POST: ESP32 INGRESS GATEWAY
// ==========================================================
app.post('/api/telemetry', async (req, res) => {
    try {
        const { deviceId, metrics, status } = req.body;
        
        // Construct and insert the new document
        const newRecord = new Telemetry({
            deviceId,
            metrics,
            status
        });
        
        await newRecord.save();
        
        console.log(`[Data Ingress] Telemetry saved from ${deviceId} | Status: ${status}`);
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
        // Fetch the absolute newest record for the mobile screen
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

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Backend service processing on port ${PORT}`));