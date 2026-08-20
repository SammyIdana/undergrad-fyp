const mongoose = require('mongoose');

const DeviceTokenSchema = new mongoose.Schema({
  deviceId: { type: String },
  token: { type: String, required: true, unique: true, index: true },
  platform: { type: String, default: 'unknown' },
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('DeviceToken', DeviceTokenSchema);
