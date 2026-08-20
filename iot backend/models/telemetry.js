const mongoose = require('mongoose');

const TelemetrySchema = new mongoose.Schema({
  deviceId: { type: String, required: true, index: true },
  metrics: {
    temperature: { type: Number, required: true },
    tds_ppm: { type: Number, required: true },
    turbidity_ntu: { type: Number, required: true },
    ph: { type: Number, required: true },
  },
  status: { type: String, required: true },
  timestamp: { type: Date, default: Date.now, index: -1 },
});

module.exports = mongoose.model('Telemetry', TelemetrySchema);
