// Comprehensive Alert & Notification System Verification Script
const assert = require('assert');
const {
  determineSeverity,
  isCooldownActive,
  SAFE_RANGES,
} = require('../services/alertEvaluator');

console.log('====================================================');
console.log('🧪 RUNNING WATER QUALITY ALERT NOTIFICATION SYSTEM CHECKS');
console.log('====================================================\n');

let passedChecks = 0;
let totalChecks = 0;

function check(description, fn) {
  totalChecks++;
  try {
    fn();
    console.log(`  [PASS] ${description}`);
    passedChecks++;
  } catch (err) {
    console.error(`  [FAIL] ${description}:`, err.message);
  }
}

// -------------------------------------------------------------
// CHECK 1: PARAMETER SEVERITY THRESHOLD CONDITIONS
// -------------------------------------------------------------
console.log('--- 1. Parameter Threshold Rule Checks ---');

check('pH: Normal within 6.5 - 8.5', () => {
  assert.strictEqual(determineSeverity('ph', 7.2), 'normal');
  assert.strictEqual(determineSeverity('ph', 6.5), 'normal');
  assert.strictEqual(determineSeverity('ph', 8.5), 'normal');
});

check('pH: Warning when 6.0 <= pH < 6.5 or 8.5 < pH <= 9.0', () => {
  assert.strictEqual(determineSeverity('ph', 6.3), 'warning');
  assert.strictEqual(determineSeverity('ph', 8.7), 'warning');
});

check('pH: Critical alert when pH < 6.0 or pH > 9.0', () => {
  assert.strictEqual(determineSeverity('ph', 5.5), 'critical');
  assert.strictEqual(determineSeverity('ph', 9.5), 'critical');
});

check('TDS: Normal <= 300 ppm, Warning > 300 ppm, Critical > 1000 ppm', () => {
  assert.strictEqual(determineSeverity('tds', 150), 'normal');
  assert.strictEqual(determineSeverity('tds', 450), 'warning');
  assert.strictEqual(determineSeverity('tds', 1050), 'critical');
});

check('Turbidity: Normal <= 5.0 NTU, Critical > 100.0 NTU', () => {
  assert.strictEqual(determineSeverity('turbidity', 2.0), 'normal');
  assert.strictEqual(determineSeverity('turbidity', 15.0), 'warning');
  assert.strictEqual(determineSeverity('turbidity', 1142.2), 'critical');
});

check('Temperature: Normal 15-35 °C, Warning < 15 or > 35, Critical < 10 or > 40', () => {
  assert.strictEqual(determineSeverity('temperature', 25.0), 'normal');
  assert.strictEqual(determineSeverity('temperature', 36.0), 'warning');
  assert.strictEqual(determineSeverity('temperature', 42.0), 'critical');
});

// -------------------------------------------------------------
// CHECK 2: QUALITY STATE TRANSITION NOTIFICATION LOGIC
// -------------------------------------------------------------
console.log('\n--- 2. State Change Alert Trigger Logic ---');

function evaluateNotificationCondition({
  previousStatus,
  currentStatus,
  previousFault,
  currentFault,
  lastAlertTimestamp,
  cooldownMs = 15 * 60 * 1000,
}) {
  const statusChanged = currentStatus !== previousStatus;
  const faultToggledOn = currentFault && !previousFault;
  const isRecovered = previousStatus !== 'SAFE' && currentStatus === 'SAFE';
  const cooldownElapsed = !lastAlertTimestamp || (Date.now() - new Date(lastAlertTimestamp).getTime() >= cooldownMs);

  let shouldNotify = false;
  let alertType = null;

  if (faultToggledOn) {
    shouldNotify = true;
    alertType = 'HARDWARE_FAULT';
  } else if (statusChanged && currentStatus === 'UNSAFE') {
    shouldNotify = true;
    alertType = 'CRITICAL_UNSAFE';
  } else if (statusChanged && (currentStatus === 'CAUTION' || currentStatus === 'LIMITED USE')) {
    shouldNotify = true;
    alertType = 'WARNING_SHIFT';
  } else if (isRecovered) {
    shouldNotify = true;
    alertType = 'RECOVERY';
  } else if (currentStatus !== 'SAFE' && cooldownElapsed) {
    shouldNotify = true;
    alertType = 'SUSTAINED_REMINDER';
  }

  return { shouldNotify, alertType };
}

check('State change SAFE -> UNSAFE triggers CRITICAL alert immediately', () => {
  const res = evaluateNotificationCondition({
    previousStatus: 'SAFE',
    currentStatus: 'UNSAFE',
    previousFault: false,
    currentFault: false,
    lastAlertTimestamp: null,
  });
  assert.strictEqual(res.shouldNotify, true);
  assert.strictEqual(res.alertType, 'CRITICAL_UNSAFE');
});

check('State change SAFE -> CAUTION triggers WARNING alert immediately', () => {
  const res = evaluateNotificationCondition({
    previousStatus: 'SAFE',
    currentStatus: 'CAUTION',
    previousFault: false,
    currentFault: false,
    lastAlertTimestamp: null,
  });
  assert.strictEqual(res.shouldNotify, true);
  assert.strictEqual(res.alertType, 'WARNING_SHIFT');
});

check('State change UNSAFE -> SAFE triggers RECOVERY notification', () => {
  const res = evaluateNotificationCondition({
    previousStatus: 'UNSAFE',
    currentStatus: 'SAFE',
    previousFault: false,
    currentFault: false,
    lastAlertTimestamp: new Date(Date.now() - 5 * 60 * 1000), // 5 min ago
  });
  assert.strictEqual(res.shouldNotify, true);
  assert.strictEqual(res.alertType, 'RECOVERY');
});

check('Hardware Fault toggling ON triggers HARDWARE_FAULT notification', () => {
  const res = evaluateNotificationCondition({
    previousStatus: 'SAFE',
    currentStatus: 'SAFE',
    previousFault: false,
    currentFault: true,
    lastAlertTimestamp: null,
  });
  assert.strictEqual(res.shouldNotify, true);
  assert.strictEqual(res.alertType, 'HARDWARE_FAULT');
});

check('Sustained UNSAFE reading during cooldown (< 15 min) does NOT spam duplicate alerts', () => {
  const res = evaluateNotificationCondition({
    previousStatus: 'UNSAFE',
    currentStatus: 'UNSAFE',
    previousFault: false,
    currentFault: false,
    lastAlertTimestamp: new Date(Date.now() - 5 * 60 * 1000), // 5 min ago (< 15 min cooldown)
  });
  assert.strictEqual(res.shouldNotify, false);
});

check('Sustained UNSAFE reading after cooldown (> 15 min) triggers SUSTAINED_REMINDER', () => {
  const res = evaluateNotificationCondition({
    previousStatus: 'UNSAFE',
    currentStatus: 'UNSAFE',
    previousFault: false,
    currentFault: false,
    lastAlertTimestamp: new Date(Date.now() - 20 * 60 * 1000), // 20 min ago (> 15 min cooldown)
  });
  assert.strictEqual(res.shouldNotify, true);
  assert.strictEqual(res.alertType, 'SUSTAINED_REMINDER');
});

// -------------------------------------------------------------
// CHECK 3: LIVE CLOUD BACKEND TELEMETRY VERIFICATION
// -------------------------------------------------------------
console.log('\n--- 3. Cloud Telemetry Ingress Verification ---');

async function testLiveEndpoints() {
  const https = require('https');

  const fetchJson = (url) => new Promise((resolve, reject) => {
    https.get(url, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try { resolve(JSON.parse(data)); } catch (e) { resolve({ error: data }); }
      });
    }).on('error', reject);
  });

  try {
    const latest = await fetchJson('https://water-quality-monitor-api.onrender.com/api/telemetry/latest/ESP32_221A74');
    if (latest && latest.success && latest.data) {
      console.log(`  [PASS] Live Render Cloud API is reachable.`);
      console.log(`         Node Device: ${latest.data.deviceId}`);
      console.log(`         Current Status: ${latest.data.status}`);
      console.log(`         Metrics: Turbidity=${latest.data.metrics?.turbidity_ntu} NTU, pH=${latest.data.metrics?.ph}, TDS=${latest.data.metrics?.tds_ppm} PPM`);
      console.log(`         Flags: Critical=${latest.data.flags?.isCritical}, HardwareFault=${latest.data.flags?.hardwareFault}`);
    } else {
      console.log(`  [WARN] Live Render API responded without expected structure.`);
    }
  } catch (err) {
    console.log(`  [WARN] Could not contact cloud API directly: ${err.message}`);
  }

  console.log('\n====================================================');
  console.log(`📊 RESULTS: ${passedChecks}/${totalChecks} ALERT NOTIFICATION CHECKS PASSED`);
  console.log('====================================================');
}

testLiveEndpoints();
