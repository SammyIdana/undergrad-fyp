const assert = require('assert');
const { generateLocalInsight } = require('../services/aiInsight');

function runTests() {
  console.log('Running AI insight tests...');
  let passed = 0;

  // Test 1: Ideal water - all params in safe range
  {
    const r = generateLocalInsight('DEV1',
      { ph: 7.2, tds_ppm: 200, turbidity_ntu: 0.5, temperature: 22 }, 'SAFE');
    assert.strictEqual(r.assessment, 'ACCEPTABLE', 'Test 1a: SAFE water assessment');
    assert.strictEqual(r.deviceId, 'DEV1',        'Test 1b: deviceId passthrough');
    assert.strictEqual(r.status, 'SAFE',           'Test 1c: status passthrough');
    assert(r.confidence >= 0.85,                   'Test 1d: confidence >= 0.85 for safe water');
    assert(Array.isArray(r.recommendations),       'Test 1e: recommendations is array');
    assert(typeof r.summary === 'string',          'Test 1f: summary is string');
    assert(typeof r.generatedAt === 'string',      'Test 1g: generatedAt is string');
    console.log('  [PASS] Test 1: Ideal safe water');
    passed++;
  }

  // Test 2: Slightly acidic pH - warning
  {
    const r = generateLocalInsight('DEV2',
      { ph: 6.2, tds_ppm: 200, turbidity_ntu: 0.5, temperature: 22 }, 'CAUTION');
    assert.strictEqual(r.assessment, 'ATTENTION REQUIRED', 'Test 2a: slightly acidic pH');
    assert(r.confidence >= 0.80,                           'Test 2b: reasonable confidence');
    assert(r.recommendations.length >= 1,                  'Test 2c: has recommendation');
    console.log('  [PASS] Test 2: Slightly acidic pH (warning)');
    passed++;
  }

  // Test 3: Critically low pH - critical
  {
    const r = generateLocalInsight('DEV3',
      { ph: 4.5, tds_ppm: 200, turbidity_ntu: 0.5, temperature: 22 }, 'DANGEROUS');
    assert.strictEqual(r.assessment, 'UNSAFE - ACT NOW', 'Test 3a: critical pH assessment');
    assert(r.summary.toLowerCase().includes('critical'), 'Test 3b: summary mentions critical');
    console.log('  [PASS] Test 3: Critically low pH');
    passed++;
  }

  // Test 4: High turbidity - critical
  {
    const r = generateLocalInsight('DEV4',
      { ph: 7.0, tds_ppm: 200, turbidity_ntu: 6.5, temperature: 22 }, 'DANGEROUS');
    assert.strictEqual(r.assessment, 'UNSAFE - ACT NOW', 'Test 4a: high turbidity is critical');
    assert(r.recommendations.length <= 3,               'Test 4b: max 3 recommendations');
    console.log('  [PASS] Test 4: High turbidity');
    passed++;
  }

  // Test 5: Elevated TDS - warning
  {
    const r = generateLocalInsight('DEV5',
      { ph: 7.0, tds_ppm: 750, turbidity_ntu: 0.5, temperature: 22 }, 'CAUTION');
    assert.strictEqual(r.assessment, 'ATTENTION REQUIRED', 'Test 5a: elevated TDS warning');
    assert(r.summary.toLowerCase().includes('range') ||
           r.summary.toLowerCase().includes('parameter'), 'Test 5b: summary describes issue');
    console.log('  [PASS] Test 5: Elevated TDS (warning)');
    passed++;
  }

  // Test 6: Critically high TDS
  {
    const r = generateLocalInsight('DEV6',
      { ph: 7.0, tds_ppm: 1200, turbidity_ntu: 0.5, temperature: 22 }, 'DANGEROUS');
    assert.strictEqual(r.assessment, 'UNSAFE - ACT NOW', 'Test 6a: critical TDS');
    assert(r.recommendations[0].toLowerCase().includes('ro') ||
           r.recommendations[0].toLowerCase().includes('filter'), 'Test 6b: RO/filter recommendation');
    console.log('  [PASS] Test 6: Critically high TDS');
    passed++;
  }

  // Test 7: High temperature - warning
  {
    const r = generateLocalInsight('DEV7',
      { ph: 7.0, tds_ppm: 200, turbidity_ntu: 0.5, temperature: 38 }, 'CAUTION');
    assert.strictEqual(r.assessment, 'ATTENTION REQUIRED', 'Test 7a: high temperature warning');
    console.log('  [PASS] Test 7: High temperature');
    passed++;
  }

  // Test 8: Multiple issues - worst severity wins
  {
    const r = generateLocalInsight('DEV8',
      { ph: 5.0, tds_ppm: 1500, turbidity_ntu: 8.0, temperature: 40 }, 'DANGEROUS');
    assert.strictEqual(r.assessment, 'UNSAFE - ACT NOW',  'Test 8a: multiple critical params');
    assert(r.recommendations.length === 3,                'Test 8b: capped at 3 recommendations');
    console.log('  [PASS] Test 8: Multiple simultaneous critical parameters');
    passed++;
  }

  // Test 9: Monitor - minor deviation only
  {
    const r = generateLocalInsight('DEV9',
      { ph: 7.0, tds_ppm: 400, turbidity_ntu: 0.5, temperature: 22 }, 'CAUTION');
    assert.strictEqual(r.assessment, 'MONITOR', 'Test 9a: minor TDS -> MONITOR');
    console.log('  [PASS] Test 9: Minor deviation (MONITOR)');
    passed++;
  }

  // Test 10: Null/missing metrics use safe defaults
  {
    const r = generateLocalInsight('DEV10', {}, 'SAFE');
    assert.strictEqual(r.assessment, 'ACCEPTABLE', 'Test 10: defaults to safe when metrics empty');
    console.log('  [PASS] Test 10: Empty metrics default to safe');
    passed++;
  }

  console.log('All ' + passed + '/10 AI insight tests passed.');
}

runTests();
