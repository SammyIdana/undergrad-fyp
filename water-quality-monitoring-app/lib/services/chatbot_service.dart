import '../models/chat_message.dart';
import '../models/water_data.dart';

class ChatbotService {
  /// Diagnose a forwarded alert and produce structured causes and corrective actions
  static ChatMessage diagnoseAlert({
    required String alertId,
    required String severity,
    required String message,
    String? deviceId,
  }) {
    final lowerMsg = message.toLowerCase();
    final causes = <String>[];
    final measures = <String>[];
    String summary = '';

    if (lowerMsg.contains('turbidity')) {
      causes.addAll([
        'Sediment or silt disturbance in the supply tank or inlet piping.',
        'Heavy stormwater runoff or soil erosion entering the reservoir.',
        'Breach or saturation of sediment filtration media/cartridge.',
        'Organic matter, microbial blooms, or pipe corrosion scaling.',
      ]);
      measures.addAll([
        'IMMEDIATE: Halt water intake or switch to an auxiliary clean supply. Do not consume directly.',
        'Inspect and backwash the primary sediment / sand filter; replace worn 5-micron cartridges.',
        'Allow water to settle in a clarifier tank with food-grade coagulant (alum) if turbidity exceeds 100 NTU.',
        'Verify optical cleanliness of the ESP32 turbidity sensor prism to rule out optical fouling.',
      ]);
      summary = 'I analyzed the forwarded Turbidity alert. Elevated turbidity makes water cloudy and protects pathogenic bacteria from disinfection.';
    } else if (lowerMsg.contains('ph')) {
      if (lowerMsg.contains('low') || lowerMsg.contains('acid')) {
        causes.addAll([
          'Acidic groundwater seepage or acid rain runoff.',
          'Decaying organic matter and tannin release.',
          'Dissolution of metallic pipes (copper, lead) due to corrosiveness.',
        ]);
        measures.addAll([
          'IMMEDIATE: Avoid drinking acidic water; it accelerates heavy metal leaching from plumbing.',
          'Install or recharge a neutralizing calcite (calcium carbonate) filter.',
          'Dose alkaline buffer (sodium carbonate/bicarbonate) for closed storage systems.',
          'Recalibrate the analog pH sensor probe using 4.01 and 7.00 buffer solutions.',
        ]);
        summary = 'I analyzed the acidic pH alert. Acidic water is corrosive to plumbing and poses gastrointestinal health hazards.';
      } else {
        causes.addAll([
          'High mineral alkalinity from limestone, dolomite, or hard water aquifers.',
          'Algal photosynthesis consuming dissolved carbon dioxide in standing tanks.',
          'Over-dosing of basic cleaning chemicals or alkaline water treatment.',
        ]);
        measures.addAll([
          'IMMEDIATE: Avoid prolonged consumption; highly alkaline water can cause bitter taste and skin irritation.',
          'Blend supply with lower pH source or use an approved mild acid dosing system (citric/hydrochloric).',
          'Use an ion-exchange water softener to balance carbonate hardness.',
          'Inspect storage tank for sunlight exposure to reduce algae proliferation.',
        ]);
        summary = 'I analyzed the high alkaline pH alert. Excessive alkalinity can scale pipes and reduce sanitizer efficacy.';
      }
    } else if (lowerMsg.contains('tds') || lowerMsg.contains('solids')) {
      causes.addAll([
        'Dissolved mineral salts (calcium, magnesium, chlorides, sulfates) from bedrock.',
        'Agricultural fertilizer runoff or industrial effluent discharge.',
        'Seawater intrusion or saline water table seepage.',
        'Old galvanised or copper pipe degradation.',
      ]);
      measures.addAll([
        'IMMEDIATE: If TDS exceeds 1000 ppm, do not use as drinking water.',
        'Deploy a multi-stage Reverse Osmosis (RO) filtration unit to reject up to 98% of dissolved salts.',
        'Install a dual-tank water softener if hardness minerals (Ca2+, Mg2+) predominate.',
        'Check sensor probe contacts for mineral salt crusting and clean with distilled water.',
      ]);
      summary = 'I analyzed the elevated Total Dissolved Solids (TDS) alert. High TDS impairs taste, clogs fixtures, and indicates potential mineral contamination.';
    } else if (lowerMsg.contains('temp')) {
      causes.addAll([
        'Exposed overhead supply pipes or uninsulated storage tanks in direct sunlight.',
        'Proximity to industrial heating equipment, boilers, or pump thermal release.',
        'Shallow distribution lines influenced by hot ambient daytime temperatures.',
      ]);
      measures.addAll([
        'IMMEDIATE: High water temperatures (>30°C) dramatically accelerate bacterial and Legionella growth.',
        'Insulate surface distribution pipes and shade exposed outdoor water tanks.',
        'Ensure continuous circulation or regular flushing of dead-leg pipe runs.',
        'Verify waterproof thermistor / DS18B20 calibration.',
      ]);
      summary = 'I analyzed the Temperature anomaly alert. Elevated temperatures foster rapid biological contamination.';
    } else {
      causes.addAll([
        'Simultaneous multi-parameter excursion exceeding calibrated safety thresholds.',
        'Contaminant plume or sudden changes in raw water source conditions.',
        'Sensor hardware disconnection or intermittent telemetry glitches.',
      ]);
      measures.addAll([
        'Isolate the monitoring zone and cross-check physical samples with portable test strips.',
        'Inspect the IoT probe cluster wiring, ADC lines, and power supply stability.',
        'Flush the line for 3 minutes before recording a fresh set of verification readings.',
      ]);
      summary = 'I analyzed the forwarded critical incident alert for device ${deviceId ?? "ESP32"}.';
    }

    return ChatMessage(
      id: 'diag_${DateTime.now().millisecondsSinceEpoch}',
      sender: MessageSender.assistant,
      text: summary,
      timestamp: DateTime.now(),
      possibleCauses: causes,
      correctiveMeasures: measures,
      forwardedContext: 'Alert: $message (${severity.toUpperCase()})',
      isDiagnosis: true,
    );
  }

  /// Diagnose live telemetry snapshot
  static ChatMessage diagnoseTelemetry(WaterData data) {
    final causes = <String>[];
    final measures = <String>[];
    final issues = <String>[];

    // Turbidity diagnosis
    if (data.turbidity > 4.0) {
      issues.add('Turbidity is dangerously high (${data.turbidity.toStringAsFixed(1)} NTU)');
      causes.add('Turbidity: Sediment upheaval, mud/silt runoff, pipe erosion, or failed cartridge filter.');
      measures.add('Turbidity: Do not drink without filtration. Backwash sand/media filter; install 5-micron sediment cartridge.');
    } else if (data.turbidity > 1.0) {
      issues.add('Turbidity is elevated (${data.turbidity.toStringAsFixed(1)} NTU)');
      causes.add('Turbidity: Fine particulate suspension or initial media breakthrough.');
      measures.add('Turbidity: Flush the tap for 2-3 minutes. Monitor filter pressure differential.');
    }

    // pH diagnosis
    if (data.ph < 6.0 && data.ph > 0.0) {
      issues.add('pH is acidic (${data.ph.toStringAsFixed(1)})');
      causes.add('pH: Acidic groundwater or dissolved organic acids corroding pipe walls.');
      measures.add('pH: Neutralize with calcite/limestone filtration bed. Avoid drinking to prevent metal ingestion.');
    } else if (data.ph > 8.5) {
      issues.add('pH is alkaline (${data.ph.toStringAsFixed(1)})');
      causes.add('pH: Mineral carbonate excess, hard limestone bedrock, or algae blooming.');
      measures.add('pH: Blend with lower pH sources; inspect outdoor tanks for algal mats.');
    }

    // TDS diagnosis
    if (data.tds > 1000.0) {
      issues.add('TDS is critical (${data.tds.toStringAsFixed(0)} ppm)');
      causes.add('TDS: Severe mineral saturation, fertilizer contamination, or saltwater intrusion.');
      measures.add('TDS: Use Reverse Osmosis (RO) purification. Do not use for drinking or cooking until lowered.');
    } else if (data.tds > 600.0) {
      issues.add('TDS is elevated (${data.tds.toStringAsFixed(0)} ppm)');
      causes.add('TDS: Hard water minerals (calcium, magnesium) exceeding pleasant taste limits.');
      measures.add('TDS: Install an RO unit or ion-exchange resin softener.');
    }

    // Temperature diagnosis
    if (data.temperature > 35.0) {
      issues.add('Temperature is elevated (${data.temperature.toStringAsFixed(1)} °C)');
      causes.add('Temperature: Solar heating of tanks/pipes; raises microbial growth rates.');
      measures.add('Temperature: Shade outdoor storage tanks; insulate exposed piping.');
    }

    if (issues.isEmpty) {
      causes.add('All parameters (pH, TDS, Turbidity, Temperature) are in safe WHO/EPA ranges.');
      measures.add('Maintain regular scheduled sensor cleaning and monthly calibration checkups.');
      return ChatMessage(
        id: 'telemetry_${DateTime.now().millisecondsSinceEpoch}',
        sender: MessageSender.assistant,
        text: 'Telemetry Diagnosis for Device ${data.deviceId}:\n\n✅ Water parameters are within safe ranges (pH ${data.ph.toStringAsFixed(1)}, TDS ${data.tds.toStringAsFixed(0)} ppm, Turbidity ${data.turbidity.toStringAsFixed(1)} NTU, Temp ${data.temperature.toStringAsFixed(1)}°C). The water is currently safe for normal use.',
        timestamp: DateTime.now(),
        possibleCauses: causes,
        correctiveMeasures: measures,
        forwardedContext: 'Live Telemetry Snapshot (${data.status})',
        isDiagnosis: true,
      );
    }

    return ChatMessage(
      id: 'telemetry_${DateTime.now().millisecondsSinceEpoch}',
      sender: MessageSender.assistant,
      text: 'Telemetry Diagnosis for Device ${data.deviceId}:\n\n⚠️ Detected ${issues.length} parameter issue(s):\n• ${issues.join('\n• ')}\n\nReview the root causes and actionable corrective measures below:',
      timestamp: DateTime.now(),
      possibleCauses: causes,
      correctiveMeasures: measures,
      forwardedContext: 'Live Telemetry: Turbidity ${data.turbidity.toStringAsFixed(1)} NTU | pH ${data.ph.toStringAsFixed(1)} | TDS ${data.tds.toStringAsFixed(0)} ppm | Temp ${data.temperature.toStringAsFixed(1)}°C',
      isDiagnosis: true,
    );
  }

  /// General conversational water specialist Q&A
  static ChatMessage answerQuery(String query, {WaterData? currentData}) {
    final q = query.toLowerCase().trim();
    final causes = <String>[];
    final measures = <String>[];
    String answer = '';

    if (q.contains('turbid') || q.contains('cloudy') || q.contains('dirty')) {
      answer = 'Turbidity measures the cloudiness or haziness of water caused by suspended particulates (clay, silt, organic matter, microorganisms). According to WHO guidelines, drinking water turbidity should ideally be < 1.0 NTU and must not exceed 4.0 NTU.';
      causes.addAll([
        'Pipe sediment re-suspension due to pressure fluctuations.',
        'Rainfall / runoff washing soil and debris into storage or source wells.',
        'Exhausted or ruptured mechanical filter cartridges.',
        'Optical sensor prism fouling from algae or bio-film buildup.',
      ]);
      measures.addAll([
        'Install a multi-stage sediment filter (20-micron pre-filter + 5-micron polishing filter).',
        'For high turbidity (>50 NTU), use alum coagulant settling before filtration.',
        'Do not drink untreated cloudy water; boil or filter through certified ceramic/RO filters.',
        'Clean the sensor glass face with an isopropyl alcohol swab and recalibrate.',
      ]);
    } else if (q.contains('tds') || q.contains('dissolved') || q.contains('salt') || q.contains('ppm')) {
      answer = 'TDS (Total Dissolved Solids) represents the total concentration of dissolved substances in water, primarily calcium, magnesium, sodium, chlorides, and carbonates. Recommended drinking limit is below 300-500 ppm; above 1000 ppm is considered unacceptable.';
      causes.addAll([
        'High natural mineral deposits in surrounding rock or groundwater aquifer.',
        'Agricultural runoff carrying fertilizer salts (nitrates, phosphates).',
        'Road salt de-icing drainage or coastal seawater intrusion.',
        'Plumbing pipe leaching and corrosion.',
      ]);
      measures.addAll([
        'Use Reverse Osmosis (RO) systems to remove 90-99% of dissolved solids.',
        'For hard scale-forming water (calcium/magnesium), install a salt-based water softener.',
        'Perform distillation for small-volume high-purity laboratory or drinking needs.',
        'Inspect TDS sensor electrical pins for mineral scale and rinse in deionized water.',
      ]);
    } else if (q.contains('ph') || q.contains('acid') || q.contains('alkali')) {
      answer = 'pH measures how acidic (0-6.9) or alkaline (7.1-14) water is. The optimal range for safe drinking water is 6.5 to 8.5. Water outside this range causes taste issues, reduces chlorine disinfection, and corrodes pipes.';
      causes.addAll([
        'Low pH (<6.5): Acid rain, decaying humus, mine drainage, and carbon dioxide absorption.',
        'High pH (>8.5): Limestone or dolomite geology, mineral leaching, or algal activity consuming CO2.',
      ]);
      measures.addAll([
        'For low pH: Pass water through a calcite (calcium carbonate) or magnesium oxide neutralizing filter.',
        'For high pH: Dose mild food-grade citric or food-grade acid, or blend with rainwater.',
        'Calibrate the pH electrode with standard 4.00, 7.00, and 10.00 pH buffer solutions regularly.',
      ]);
    } else if (q.contains('drink') || q.contains('safe') || q.contains('status')) {
      if (currentData != null) {
        final isSafe = currentData.status == 'SAFE' ||
            (currentData.turbidity <= 4.0 && currentData.ph >= 6.5 && currentData.ph <= 8.5 && currentData.tds <= 1000.0);
        if (isSafe) {
          answer = 'Based on the latest sensor readings from device ${currentData.deviceId}, your water is currently within acceptable health parameters. Turbidity (${currentData.turbidity.toStringAsFixed(1)} NTU), pH (${currentData.ph.toStringAsFixed(1)}), and TDS (${currentData.tds.toStringAsFixed(0)} ppm) meet baseline safety guidelines.';
          measures.add('Continue routine continuous monitoring and periodic filter replacements.');
        } else {
          answer = '⚠️ WARNING: Based on current sensor readings, your water is NOT considered safe for direct consumption without treatment. One or more parameters exceed safe thresholds (Status: ${currentData.status}).';
          if (currentData.turbidity > 4.0) {
            causes.add('Turbidity is dangerously high (${currentData.turbidity.toStringAsFixed(1)} NTU), harboring microbial pathogens.');
            measures.add('Halt drinking intake; boil and filter through fine sediment cartridges.');
          }
          if (currentData.tds > 1000.0) {
            causes.add('TDS is critically high (${currentData.tds.toStringAsFixed(0)} ppm).');
            measures.add('Run water through an active Reverse Osmosis (RO) unit.');
          }
          if (currentData.ph < 6.5 || currentData.ph > 8.5) {
            causes.add('pH is out of recommended range (${currentData.ph.toStringAsFixed(1)}).');
            measures.add('Adjust pH using neutralizing mineral cartridges.');
          }
        }
      } else {
        answer = 'To determine if water is safe to drink, verify that Turbidity is under 1.0-4.0 NTU, pH is between 6.5 and 8.5, and TDS is under 500-1000 ppm. Forward your current telemetry or alert to get an instant safety verdict.';
        measures.add('Tap "Diagnose Current Water" on your dashboard to run an automated check.');
      }
    } else if (q.contains('sensor') || q.contains('calibrat') || q.contains('probe') || q.contains('esp32')) {
      answer = 'Sensor Maintenance & Calibration Guide:\n\n'
          '1. pH Sensor: Immerse in standard 7.00 pH buffer, adjust offset potentiometer until ADC reads 7.00. Then test 4.01 buffer to set slope.\n\n'
          '2. Turbidity Sensor: Keep optical prism clean with alcohol swabs. Measure in pure distilled water (0 NTU reference) and adjust threshold trimmer.\n\n'
          '3. TDS Sensor: Ensure the two metal pin probes are completely submerged without touching the container walls. Calibrate using 1413 µS/cm reference standard solution.\n\n'
          '4. Temperature (DS18B20): Waterproof digital probe requires a 4.7kΩ pull-up resistor between DATA and VCC (3.3V/5V).';
      measures.add('Perform calibration every 30-60 days to prevent drift.');
      measures.add('Ensure analog ground (GND) is clean and isolated from noisy relay or pump coils.');
    } else {
      answer = 'I am your Water Quality AI Assistant. I specialize in diagnosing water anomalies, identifying potential root causes, and prescribing corrective actions.\n\n'
          'You can ask me about:\n'
          '• Root causes for high Turbidity, TDS, or pH swings\n'
          '• Immediate corrective filtration and purification measures\n'
          '• Whether your current water readings are safe to drink\n'
          '• Sensor calibration and ESP32 hardware troubleshooting';
      measures.add('Forward any alert from the Alert History screen or tap one of the quick suggestions below.');
    }

    return ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      sender: MessageSender.assistant,
      text: answer,
      timestamp: DateTime.now(),
      possibleCauses: causes.isNotEmpty ? causes : null,
      correctiveMeasures: measures.isNotEmpty ? measures : null,
      isDiagnosis: causes.isNotEmpty || measures.isNotEmpty,
    );
  }
}
