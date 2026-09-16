const fs = require('fs');

function evaluatePh(ph) {
  const issues = [], recs = [];
  let sev = 'normal';
  if (ph < 6.0 || ph > 9.0) {
    sev = 'critical';
    if (ph < 6.0) {
      issues.push('pH is critically low (' + ph.toFixed(1) + ') - highly acidic water');
      recs.push('Stop using this water immediately. Contact your water authority.');
    } else {
      issues.push('pH is critically high (' + ph.toFixed(1) + ') - strongly alkaline water');
      recs.push('Avoid drinking this water. Have it tested by a certified laboratory.');
    }
  } else if (ph < 6.5 || ph > 8.5) {
    sev = 'warning';
    if (ph < 6.5) {
      issues.push('pH is slightly acidic (' + ph.toFixed(1) + ')');
      recs.push('Filter through a pH-balancing cartridge and retest within 24 hours.');
    } else {
      issues.push('pH is slightly alkaline (' + ph.toFixed(1) + ')');
      recs.push('Monitor pH daily. Consult your water supplier if it continues rising.');
    }
  }
  return { sev, issues, recs };
}

function evaluateTds(tds) {
  const issues = [], recs = [];
  let sev = 'normal';
  if (tds > 1000) {
    sev = 'critical';
    issues.push('TDS is critically elevated (' + Math.round(tds) + ' ppm) - far above safe limits');
    recs.push('Do not drink this water. Use an RO filter or an alternative clean supply immediately.');
  } else if (tds > 600) {
    sev = 'warning';
    issues.push('TDS is high (' + Math.round(tds) + ' ppm) - exceeds the 600 ppm recommended limit');
    recs.push('Use a multi-stage filter to reduce dissolved solids before consumption.');
  } else if (tds > 300) {
    sev = 'minor';
    issues.push('TDS is moderately elevated (' + Math.round(tds) + ' ppm)');
    recs.push('Water is acceptable; a carbon block filter can improve taste.');
  }
  return { sev, issues, recs };
}

function evaluateTurbidity(turb) {
  const issues = [], recs = [];
  let sev = 'normal';
  if (turb > 4) {
    sev = 'critical';
    issues.push('Turbidity is very high (' + turb.toFixed(1) + ' NTU) - water is visibly cloudy');
    recs.push('Do not consume this water. Use certified bottled water until clarity improves.');
    recs.push('Check for sediment buildup in pipes or a breach in the filtration system.');
  } else if (turb > 1) {
    sev = 'warning';
    issues.push('Turbidity is elevated (' + turb.toFixed(1) + ' NTU) - above the ideal 1 NTU');
    recs.push('Flush the tap for 2-3 minutes. If cloudiness persists, replace filter cartridges.');
  }
  return { sev, issues, recs };
}

function evaluateTemperature(temp) {
  const issues = [], recs = [];
  let sev = 'normal';
  if (temp > 45 || temp < 0) {
    sev = 'critical';
    issues.push('Temperature is extreme (' + temp.toFixed(1) + ' C)');
    recs.push('Check sensor calibration. If accurate, inspect supply for contamination or heating faults.');
  } else if (temp > 35) {
    sev = 'warning';
    issues.push('Water temperature is elevated (' + temp.toFixed(1) + ' C) - promotes microbial growth');
    recs.push('Insulate and shade storage tanks. Elevated temperatures accelerate bacterial growth.');
  } else if (temp < 10) {
    sev = 'minor';
    issues.push('Water temperature is cool (' + temp.toFixed(1) + ' C) - below the optimal range');
    recs.push('Temperature is within safe limits. No corrective action required.');
  }
  return { sev, issues, recs };
}

const SEVERITY_RANK = { normal: 0, minor: 1, warning: 2, critical: 3 };

function maxSev() {
  const sevs = Array.from(arguments);
  return sevs.reduce(function(best, s) {
    return (SEVERITY_RANK[s] || 0) > (SEVERITY_RANK[best] || 0) ? s : best;
  }, 'normal');
}

function calcConfidence(overallSev, status) {
  const s = (status || '').toUpperCase();
  const base = { normal: 0.92, minor: 0.88, warning: 0.85, critical: 0.90 };
  let c = base[overallSev] != null ? base[overallSev] : 0.80;
  if (overallSev === 'critical' && (s === 'SAFE' || s === 'GOOD')) c -= 0.10;
  if (overallSev === 'normal' && s === 'DANGEROUS') c -= 0.08;
  return Math.min(1.0, Math.max(0.50, parseFloat(c.toFixed(2))));
}

function buildSummary(overallSev, allIssues) {
  if (overallSev === 'normal')
    return 'All monitored parameters are within safe ranges. The water is suitable for normal use.';
  if (overallSev === 'minor')
    return 'Water quality is generally acceptable with minor deviations. ' + (allIssues[0] || 'Continue monitoring.');
  if (overallSev === 'warning') {
    const n = allIssues.length;
    return n + ' parameter' + (n > 1 ? 's are' : ' is') +
      ' outside the recommended range. Attention is advised: ' +
      allIssues.slice(0, 2).join('; ') + '.';
  }
  return 'Critical water quality issue detected. ' +
    (allIssues[0] || 'One or more parameters exceed safe thresholds.') +
    ' Take corrective action before consuming this water.';
}

function buildAssessment(overallSev) {
  const map = { normal: 'ACCEPTABLE', minor: 'MONITOR', warning: 'ATTENTION REQUIRED', critical: 'UNSAFE - ACT NOW' };
  return map[overallSev] || 'UNKNOWN';
}

function generateLocalInsight(deviceId, metrics, status) {
  const ph   = metrics.ph            != null ? metrics.ph            : 7.0;
  const tds  = metrics.tds_ppm       != null ? metrics.tds_ppm       : 0;
  const turb = metrics.turbidity_ntu != null ? metrics.turbidity_ntu : 0;
  const temp = metrics.temperature   != null ? metrics.temperature   : 25;

  const phR   = evaluatePh(ph);
  const tdsR  = evaluateTds(tds);
  const turbR = evaluateTurbidity(turb);
  const tempR = evaluateTemperature(temp);

  const overallSev = maxSev(phR.sev, tdsR.sev, turbR.sev, tempR.sev);
  const allIssues  = [].concat(phR.issues, turbR.issues, tdsR.issues, tempR.issues);
  const allRecs    = [].concat(phR.recs,   turbR.recs,   tdsR.recs,   tempR.recs);
  const recs       = allRecs.filter(function(v, i, a) { return a.indexOf(v) === i; }).slice(0, 3);

  return {
    deviceId:        deviceId,
    status:          status,
    assessment:      buildAssessment(overallSev),
    confidence:      calcConfidence(overallSev, status),
    recommendations: recs.length > 0 ? recs : ['No immediate action required. Continue routine monitoring.'],
    summary:         buildSummary(overallSev, allIssues),
    generatedAt:     new Date().toISOString(),
  };
}

module.exports = { generateLocalInsight };
