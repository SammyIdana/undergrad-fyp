const admin = require('firebase-admin');
const cron = require('node-cron');
const Alert = require('../models/alert');
const DeviceToken = require('../models/deviceToken');
const Telemetry = require('../models/telemetry');
const {
  determineSeverity,
  getSafeRangeLabel,
  isCooldownActive,
  hasConsecutiveCriticalCycles,
  isSteadyTrendTowardLimit,
} = require('./alertEvaluator');

const LOCAL_TIMEZONE = process.env.LOCAL_TIMEZONE || 'Etc/UTC';
const NOTIFICATION_CHANNELS = {
  critical: 'critical_alerts',
  warning: 'system_warnings',
  summary: 'daily_summaries',
};

const DEFAULT_TOKENS_LIMIT = 500;

function getNodeDisplayName(nodeId) {
  return nodeId || 'Sensor Node';
}

function buildCollapseKey(deviceId) {
  return `node_${deviceId}`;
}

async function initializeNotificationService() {
  if (!admin.apps.length) {
    const serviceAccount = require('../firebase-service-account.json');
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
  }

  scheduleOfflineHealthCheck();
  scheduleDailySummaries();
}

async function sendPushNotification({ title, body, data = {}, channelId, collapseKey }) {
  const tokens = await DeviceToken.find({}, 'token').lean();
  if (!tokens.length) {
    console.warn('No registered device tokens available for push delivery.');
    return null;
  }

  const message = {
    tokens: tokens.map((row) => row.token),
    notification: { title, body },
    android: {
      notification: {
        channelId,
        tag: collapseKey,
      },
      collapseKey,
      priority: 'high',
    },
    apns: {
      headers: {
        'apns-collapse-id': collapseKey,
      },
      payload: {
        aps: {
          category: channelId,
          sound: channelId === NOTIFICATION_CHANNELS.critical ? 'default' : undefined,
          contentAvailable: true,
        },
      },
    },
    data,
  };

  try {
    const response = await admin.messaging().sendMulticast(message);
    console.log(`Pushed ${response.successCount} notifications (${response.failureCount} failures)`);
    return response;
  } catch (error) {
    console.error('Push dispatch failed:', error);
    return null;
  }
}

async function registerDeviceToken(deviceId, token, platform = 'unknown') {
  if (!token) return;
  try {
    await DeviceToken.updateOne(
      { token },
      { token, deviceId, platform, createdAt: new Date() },
      { upsert: true },
    );
    console.log(`Registered FCM token for device ${deviceId || 'unknown'}`);
  } catch (error) {
    console.error('Failed to register device token:', error);
  }
}

async function createAlertRecord({ deviceId, parameter, category, severity, status, message, value, threshold, collapseKey, metadata }) {
  const alert = new Alert({
    deviceId,
    parameter,
    category,
    severity,
    status,
    message,
    value,
    threshold,
    collapseKey,
    metadata: metadata || {},
    active: severity !== 'resolved',
    sentAt: new Date(),
  });
  await alert.save();
  return alert;
}

async function resolveActiveAlerts(deviceId, parameter) {
  await Alert.updateMany(
    { deviceId, parameter, active: true },
    { active: false, resolvedAt: new Date() },
  );
}

function buildParameterMessage(parameter, value, nodeId, eventType) {
  const displayName = getNodeDisplayName(nodeId);
  if (eventType === 'critical') {
    return `Critical Alert: Water ${parameter} crossed a safe threshold at ${value} on ${displayName}. Immediate action required.`;
  }
  if (eventType === 'recovery') {
    return `Resolved: Water parameters on ${displayName} returned to normal (${value}).`;
  }
  if (eventType === 'warning') {
    return `Warning: Parameter ${parameter} on ${displayName} is steadily approaching threshold limits.`;
  }
  return `Notification from ${displayName}`;
}

function generateParameterPayload(parameter, metricValue, nodeId) {
  return {
    nodeId,
    parameter,
    value: `${metricValue}`,
  };
}

function getParameterValue(record, parameter) {
  if (parameter === 'ph') return record.metrics.ph;
  if (parameter === 'tds') return record.metrics.tds_ppm;
  if (parameter === 'turbidity') return record.metrics.turbidity_ntu;
  if (parameter === 'temperature') return record.metrics.temperature;
  return null;
}

async function evaluateTelemetryRecord(record) {
  const deviceId = record.deviceId;
  const collapseKey = buildCollapseKey(deviceId);
  const history = await Telemetry.find({ deviceId }).sort({ timestamp: -1 }).limit(6).lean();

  const parameters = [
    { key: 'ph', label: 'pH' },
    { key: 'tds', label: 'TDS' },
    { key: 'turbidity', label: 'Turbidity' },
    { key: 'temperature', label: 'Temperature' },
  ];

  // Evaluate potential transitions for each parameter
  const actions = [];
  for (const parameter of parameters) {
    const currentValue = getParameterValue(record, parameter.key);
    if (currentValue == null) continue;
    const severity = determineSeverity(parameter.key, currentValue);
    const lastAlert = await Alert.findOne({ deviceId, parameter: parameter.key }).sort({ sentAt: -1 }).lean();
    const lastSeverity = lastAlert ? lastAlert.severity : 'normal';
    const lastSentAt = lastAlert ? lastAlert.sentAt : null;

    if (severity === 'critical') {
      const criticalHistory = history.map((entry) => getParameterValue(entry, parameter.key));
      if (hasConsecutiveCriticalCycles(criticalHistory, parameter.key, 2)) {
        if (lastSeverity !== 'critical') {
          actions.push({ parameter, severity: 'critical', value: currentValue });
        }
      }
    } else if (severity === 'normal' && lastSeverity === 'critical') {
      actions.push({ parameter, severity: 'recovery', value: currentValue });
    } else if (severity === 'warning') {
      const trending = isSteadyTrendTowardLimit(history.map((entry) => getParameterValue(entry, parameter.key)), parameter.key);
      if (trending && lastSeverity !== 'warning' && !isCooldownActive(lastSentAt, 30)) {
        actions.push({ parameter, severity: 'warning', value: currentValue });
      }
    }
  }

  for (const action of actions) {
    const { parameter, severity, value } = action;
    const thresholdLabel = getSafeRangeLabel(parameter.key);
    const category = severity === 'critical' ? 'Critical System Hazard' : severity === 'warning' ? 'Trend Warning' : 'System Recovery';
    const status = severity === 'recovery' ? 'resolved' : severity;
    const message = buildParameterMessage(parameter.label, value, deviceId, severity === 'recovery' ? 'recovery' : severity);
    const payload = generateParameterPayload(parameter.label, value, deviceId);

    if (severity === 'recovery') {
      await resolveActiveAlerts(deviceId, parameter.key);
    }

    await createAlertRecord({
      deviceId,
      parameter: parameter.key,
      category,
      severity,
      status,
      message,
      value,
      threshold: thresholdLabel,
      collapseKey,
      metadata: { event: severity },
    });

    await sendPushNotification({
      title: severity === 'critical'
        ? `Critical Alert: ${parameter.label}`
        : severity === 'warning'
          ? `Trend Warning: ${parameter.label}`
          : `Resolved: ${parameter.label}`,
      body: message,
      data: { ...payload, alertType: severity },
      channelId: severity === 'critical'
        ? NOTIFICATION_CHANNELS.critical
        : severity === 'warning'
          ? NOTIFICATION_CHANNELS.warning
          : NOTIFICATION_CHANNELS.summary,
      collapseKey,
    });
  }
}

async function scheduleOfflineHealthCheck() {
  cron.schedule('*/10 * * * *', async () => {
    const cutoff = new Date(Date.now() - 30 * 60 * 1000);
    const latestRecords = await Telemetry.aggregate([
      { $sort: { deviceId: 1, timestamp: -1 } },
      { $group: { _id: '$deviceId', latest: { $first: '$$ROOT' } } },
    ]);

    for (const entry of latestRecords) {
      const { _id: deviceId, latest } = entry;
      if (latest.timestamp < cutoff) {
        const lastAlert = await Alert.findOne({ deviceId, category: 'Offline Warning', active: true }).sort({ sentAt: -1 }).lean();
        if (!lastAlert || !isCooldownActive(lastAlert.sentAt, 30)) {
          const collapseKey = buildCollapseKey(deviceId);
          const message = `System Offline: Telemetry lost for ${getNodeDisplayName(deviceId)} for over 30 minutes.`;
          await createAlertRecord({
            deviceId,
            parameter: 'offline',
            category: 'Offline Warning',
            severity: 'warning',
            status: 'warning',
            message,
            collapseKey,
            metadata: { lastSeen: latest.timestamp },
          });
          await sendPushNotification({
            title: 'System Offline',
            body: message,
            data: { nodeId: deviceId, alertType: 'offline' },
            channelId: NOTIFICATION_CHANNELS.warning,
            collapseKey,
          });
        }
      }
    }
  }, {
    timezone: LOCAL_TIMEZONE,
  });
}

async function scheduleDailySummaries() {
  cron.schedule('0 8 * * *', async () => {
    const devices = await Telemetry.distinct('deviceId');
    const now = new Date();
    const dayAgo = new Date(now.getTime() - 24 * 60 * 60 * 1000);

    for (const deviceId of devices) {
      const recentTelemetry = await Telemetry.find({ deviceId, timestamp: { $gte: dayAgo } }).lean();
      if (!recentTelemetry.length) {
        continue;
      }
      const summaryText = recentTelemetry.every((entry) => {
        const ph = entry.metrics.ph;
        const tds = entry.metrics.tds_ppm;
        const turbidity = entry.metrics.turbidity_ntu;
        const temp = entry.metrics.temperature;
        return (
          determineSeverity('ph', ph) === 'normal' &&
          determineSeverity('tds', tds) === 'normal' &&
          determineSeverity('turbidity', turbidity) === 'normal' &&
          determineSeverity('temperature', temp) === 'normal'
        );
      })
        ? 'Daily Report: All parameters remained within optimal thresholds for the last 24h.'
        : 'Daily Report: One or more parameters required attention in the last 24h.';

      const collapseKey = buildCollapseKey(deviceId);
      await createAlertRecord({
        deviceId,
        parameter: 'daily_summary',
        category: 'Daily Summary',
        severity: 'summary',
        status: 'summary',
        message: summaryText,
        collapseKey,
        metadata: { period: '24h' },
      });
      await sendPushNotification({
        title: 'Daily Water Quality Report',
        body: summaryText,
        data: { nodeId: deviceId, alertType: 'summary' },
        channelId: NOTIFICATION_CHANNELS.summary,
        collapseKey,
      });
    }
  }, {
    timezone: LOCAL_TIMEZONE,
  });
}

async function getAlerts(limit = 50) {
  return Alert.find().sort({ sentAt: -1 }).limit(limit).lean();
}

async function markAlertRead(alertId) {
  return Alert.findByIdAndUpdate(alertId, { read: true }).lean();
}

module.exports = {
  initializeNotificationService,
  evaluateTelemetryRecord,
  registerDeviceToken,
  getAlerts,
  markAlertRead,
};
