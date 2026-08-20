const mongoose = require('mongoose');

const AlertSchema = new mongoose.Schema({
  deviceId: { type: String, required: true, index: true },
  parameter: { type: String, required: true },
  category: { type: String, required: true },
  severity: { type: String, required: true },
  status: { type: String, required: true },
  message: { type: String, required: true },
  value: { type: Number, required: false },
  threshold: { type: String, required: false },
  collapseKey: { type: String, required: true },
  active: { type: Boolean, required: true, default: true },
  read: { type: Boolean, required: true, default: false },
  sentAt: { type: Date, default: Date.now },
  resolvedAt: { type: Date },
  metadata: { type: mongoose.Schema.Types.Mixed, default: {} },
});

module.exports = mongoose.model('Alert', AlertSchema);
