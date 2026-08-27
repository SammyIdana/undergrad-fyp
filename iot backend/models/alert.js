const mongoose = require('mongoose');

const AlertSchema = new mongoose.Schema({
  deviceId: { type: String, required: true, index: true },
  channel: { type: String, default: 'push' },
  parameter: { type: String, required: false },
  category: { type: String, required: false },
  severity: { type: String, required: false },
  status: { type: String, required: true },
  message: { type: String, required: false },
  value: { type: Number, required: false },
  threshold: { type: String, required: false },
  collapseKey: { type: String, required: false },
  active: { type: Boolean, required: true, default: true },
  read: { type: Boolean, required: true, default: false },
  timestamp: { type: Date, default: Date.now },
  sentAt: { type: Date, default: Date.now },
  resolvedAt: { type: Date },
  metadata: { type: mongoose.Schema.Types.Mixed, default: {} },
});

module.exports = mongoose.model('Alert', AlertSchema);
