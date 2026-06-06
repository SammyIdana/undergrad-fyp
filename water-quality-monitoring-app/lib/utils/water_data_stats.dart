import '../models/water_data.dart';

class WaterDataStats {
  final double minPh;
  final double maxPh;
  final double avgPh;

  final double minTds;
  final double maxTds;
  final double avgTds;

  final double minTurbidity;
  final double maxTurbidity;
  final double avgTurbidity;

  final double minTemperature;
  final double maxTemperature;
  final double avgTemperature;

  WaterDataStats({
    required this.minPh,
    required this.maxPh,
    required this.avgPh,
    required this.minTds,
    required this.maxTds,
    required this.avgTds,
    required this.minTurbidity,
    required this.maxTurbidity,
    required this.avgTurbidity,
    required this.minTemperature,
    required this.maxTemperature,
    required this.avgTemperature,
  });

  factory WaterDataStats.fromList(List<WaterData> data) {
    if (data.isEmpty) {
      return WaterDataStats(
        minPh: 0,
        maxPh: 0,
        avgPh: 0,
        minTds: 0,
        maxTds: 0,
        avgTds: 0,
        minTurbidity: 0,
        maxTurbidity: 0,
        avgTurbidity: 0,
        minTemperature: 0,
        maxTemperature: 0,
        avgTemperature: 0,
      );
    }

    // pH calculations
    double minPh = data.first.ph;
    double maxPh = data.first.ph;
    double sumPh = 0;

    // TDS calculations
    double minTds = data.first.tds;
    double maxTds = data.first.tds;
    double sumTds = 0;

    // Turbidity calculations
    double minTurbidity = data.first.turbidity;
    double maxTurbidity = data.first.turbidity;
    double sumTurbidity = 0;

    // Temperature calculations
    double minTemperature = data.first.temperature;
    double maxTemperature = data.first.temperature;
    double sumTemperature = 0;

    for (var dataPoint in data) {
      // pH
      if (dataPoint.ph < minPh) minPh = dataPoint.ph;
      if (dataPoint.ph > maxPh) maxPh = dataPoint.ph;
      sumPh += dataPoint.ph;

      // TDS
      if (dataPoint.tds < minTds) minTds = dataPoint.tds;
      if (dataPoint.tds > maxTds) maxTds = dataPoint.tds;
      sumTds += dataPoint.tds;

      // Turbidity
      if (dataPoint.turbidity < minTurbidity) minTurbidity = dataPoint.turbidity;
      if (dataPoint.turbidity > maxTurbidity) maxTurbidity = dataPoint.turbidity;
      sumTurbidity += dataPoint.turbidity;

      // Temperature
      if (dataPoint.temperature < minTemperature) {
        minTemperature = dataPoint.temperature;
      }
      if (dataPoint.temperature > maxTemperature) {
        maxTemperature = dataPoint.temperature;
      }
      sumTemperature += dataPoint.temperature;
    }

    return WaterDataStats(
      minPh: minPh,
      maxPh: maxPh,
      avgPh: sumPh / data.length,
      minTds: minTds,
      maxTds: maxTds,
      avgTds: sumTds / data.length,
      minTurbidity: minTurbidity,
      maxTurbidity: maxTurbidity,
      avgTurbidity: sumTurbidity / data.length,
      minTemperature: minTemperature,
      maxTemperature: maxTemperature,
      avgTemperature: sumTemperature / data.length,
    );
  }
}
