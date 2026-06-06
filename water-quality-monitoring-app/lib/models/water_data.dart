class WaterData {
  final String deviceId;
  final String status;
  final double ph;
  final double tds;
  final double turbidity;
  final double temperature;
  final DateTime timestamp;

  WaterData({
    required this.deviceId,
    required this.status,
    required this.ph,
    required this.tds,
    required this.turbidity,
    required this.temperature,
    required this.timestamp,
  });

  factory WaterData.fromJson(Map<String, dynamic> json) {
    // 1️⃣ Extract the nested 'data' map if it exists, otherwise fall back to root
    final rootJson = json['data'] != null ? json['data'] as Map<String, dynamic> : json;
    
    // 2️⃣ Pull metrics from inside that rootJson block
    final metrics = rootJson['metrics'] ?? {};
    
    // 3️⃣ Read and normalize status strings
    String incomingStatus = rootJson['status'] ?? 'WAITING';
    incomingStatus = incomingStatus.toUpperCase();
    
    // Map your ESP32's "UNSAFE" payload cleanly to the app's "DANGEROUS" UI state
    if (incomingStatus == 'UNSAFE') {
      incomingStatus = 'UNSAFE';
    }

    return WaterData(
      deviceId: rootJson['deviceId'] ?? 'ESP32_221A74',
      status: incomingStatus,
      ph: (metrics['ph'] as num?)?.toDouble() ?? 0.0,
      tds: (metrics['tds_ppm'] as num?)?.toDouble() ?? 0.0,
      turbidity: (metrics['turbidity_ntu'] as num?)?.toDouble() ?? 0.0,
      temperature: (metrics['temperature'] as num?)?.toDouble() ?? 25.0,
      timestamp: rootJson['timestamp'] != null 
          ? DateTime.parse(rootJson['timestamp']) 
          : (rootJson['createdAt'] != null 
              ? DateTime.parse(rootJson['createdAt']) 
              : DateTime.now()),
    );
  }
}