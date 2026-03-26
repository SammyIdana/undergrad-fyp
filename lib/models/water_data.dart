class WaterData {
  final double ph;
  final double tds;
  final double turbidity;
  final double temperature;
  final String status;
  final DateTime timestamp;

  WaterData({
    required this.ph,
    required this.tds,
    required this.turbidity,
    required this.temperature,
    required this.status,
    required this.timestamp,
  });

  factory WaterData.fromJson(Map<dynamic, dynamic> json) {
    return WaterData(
      ph: _parseDouble(json['pH']),
      tds: _parseDouble(json['TDS']),
      turbidity: _parseDouble(json['turbidity']),
      temperature: _parseDouble(json['temperature']),
      status: json['status'] ?? 'UNKNOWN',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}
