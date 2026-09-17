// Pure evaluation helpers for alert state transitions, hysteresis, and trend detection.

const SAFE_RANGES = {
  ph: { low: 6.5, high: 8.5 },
  tds: { low: 0, high: 300 },
  turbidity: { low: 0, high: 5.0 },
  temperature: { low: 15, high: 35 },
};

const CRITICAL_RANGES = {
  ph: { low: 6.0, high: 9.0 },
  turbidity: { low: 0, high: 100.0 },
  temperature: { low: 10, high: 40 },
};

function determineSeverity(parameter, value) {
  if (parameter === 'ph') {
    if (value < CRITICAL_RANGES.ph.low || value > CRITICAL_RANGES.ph.high) return 'critical';
    if (value < SAFE_RANGES.ph.low || value > SAFE_RANGES.ph.high) return 'warning';
    return 'normal';
  }

  if (parameter === 'tds') {
    if (value > 1000) return 'critical';
    if (value > SAFE_RANGES.tds.high) return 'warning';
    return 'normal';
  }

  if (parameter === 'turbidity') {
    if (value > CRITICAL_RANGES.turbidity.high) return 'critical';
    if (value > SAFE_RANGES.turbidity.high) return 'warning';
    return 'normal';
  }

  if (parameter === 'temperature') {
    if (value < CRITICAL_RANGES.temperature.low || value > CRITICAL_RANGES.temperature.high) return 'critical';
    if (value < SAFE_RANGES.temperature.low || value > SAFE_RANGES.temperature.high) return 'warning';
    return 'normal';
  }

  return 'normal';
}

function getSafeRangeLabel(parameter) {
  const range = SAFE_RANGES[parameter];
  if (!range) return 'optimal';
  return `${range.low} - ${range.high}`;
}

function isCooldownActive(lastSentAt, cooldownMinutes = 30) {
  if (!lastSentAt) return false;
  const diff = Date.now() - new Date(lastSentAt).getTime();
  return diff < cooldownMinutes * 60 * 1000;
}

function hasConsecutiveCriticalCycles(historyValues, parameter, requiredCycles = 2) {
  if (!Array.isArray(historyValues) || historyValues.length < requiredCycles) return false;
  const severityValues = historyValues.slice(0, requiredCycles).map((entry) => determineSeverity(parameter, entry));
  return severityValues.every((severity) => severity === 'critical');
}

function isSteadyTrendTowardLimit(historyValues, parameter) {
  if (!Array.isArray(historyValues) || historyValues.length < 6) return false;

  const values = historyValues.map((entry) => entry).slice(0, 6);
  const slope = values[values.length - 1] - values[0];
  const thresh = SAFE_RANGES[parameter];
  if (!thresh) return false;

  if (parameter === 'ph') {
    return slope < 0 && values[values.length - 1] < 7.0;
  }

  if (parameter === 'temperature') {
    // trending toward the nearest temperature boundary
    const mean = values.reduce((sum, v) => sum + v, 0) / values.length;
    if (mean < (thresh.low + thresh.high) / 2) return slope < 0;
    return slope > 0;
  }

  return slope > 0;
}

module.exports = {
  determineSeverity,
  getSafeRangeLabel,
  isCooldownActive,
  hasConsecutiveCriticalCycles,
  isSteadyTrendTowardLimit,
  SAFE_RANGES,
};
