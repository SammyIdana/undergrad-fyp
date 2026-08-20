const assert = require('assert');
const {
  determineSeverity,
  hasConsecutiveCriticalCycles,
  isCooldownActive,
  isSteadyTrendTowardLimit,
} = require('../services/alertEvaluator');

function runTests() {
  console.log('Running alert evaluator tests...');

  assert.strictEqual(determineSeverity('ph', 7.0), 'normal');
  assert.strictEqual(determineSeverity('ph', 5.8), 'critical');
  assert.strictEqual(determineSeverity('ph', 8.6), 'warning');
  assert.strictEqual(determineSeverity('tds', 250), 'normal');
  assert.strictEqual(determineSeverity('tds', 350), 'warning');
  assert.strictEqual(determineSeverity('tds', 520), 'critical');

  const historyCritical = [8.8, 8.9, 9.1];
  assert.strictEqual(hasConsecutiveCriticalCycles(historyCritical, 'ph', 2), true);

  const historyNormal = [7.0, 7.2, 7.1];
  assert.strictEqual(hasConsecutiveCriticalCycles(historyNormal, 'ph', 2), false);

  const now = new Date();
  const older = new Date(now.getTime() - 31 * 60 * 1000);
  assert.strictEqual(isCooldownActive(older), false);
  const recent = new Date(now.getTime() - 10 * 60 * 1000);
  assert.strictEqual(isCooldownActive(recent), true);

  const downTrend = [8.2, 8.0, 7.8, 7.6, 7.4, 7.2];
  assert.strictEqual(isSteadyTrendTowardLimit(downTrend, 'ph'), true);

  const flatTds = [270, 280, 290, 295, 298, 299];
  assert.strictEqual(isSteadyTrendTowardLimit(flatTds, 'tds'), true);

  console.log('All alert evaluator tests passed.');
}

runTests();
