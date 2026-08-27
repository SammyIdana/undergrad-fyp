const mongoose = require('mongoose');

const DeviceSchema = new mongoose.Schema({
  deviceId: { type: String, required: true, unique: true },
  fcmToken: { type: String },
  platform: { type: String, default: 'unknown' },
  lastStatus: { type: String, default: 'SAFE' },
  lastHardwareFault: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Device', DeviceSchema);
