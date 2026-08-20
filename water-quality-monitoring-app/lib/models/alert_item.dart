class AlertItem {
  final String id;
  final String deviceId;
  final String parameter;
  final String category;
  final String severity;
  final String status;
  final String message;
  final double? value;
  final String? threshold;
  final String collapseKey;
  final bool active;
  final bool read;
  final DateTime sentAt;
  final DateTime? resolvedAt;
  final Map<String, dynamic> metadata;

  AlertItem({
    required this.id,
    required this.deviceId,
    required this.parameter,
    required this.category,
    required this.severity,
    required this.status,
    required this.message,
    this.value,
    this.threshold,
    required this.collapseKey,
    required this.active,
    required this.read,
    required this.sentAt,
    this.resolvedAt,
    required this.metadata,
  });

  factory AlertItem.fromJson(Map<String, dynamic> json) {
    return AlertItem(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      deviceId: json['deviceId'] as String? ?? '',
      parameter: json['parameter'] as String? ?? '',
      category: json['category'] as String? ?? '',
      severity: json['severity'] as String? ?? 'info',
      status: json['status'] as String? ?? 'unknown',
      message: json['message'] as String? ?? '',
      value: json['value'] != null ? (json['value'] as num).toDouble() : null,
      threshold: json['threshold'] as String?,
      collapseKey: json['collapseKey'] as String? ?? '',
      active: json['active'] as bool? ?? false,
      read: json['read'] as bool? ?? false,
      sentAt: json['sentAt'] != null ? DateTime.parse(json['sentAt'] as String) : DateTime.now(),
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt'] as String) : null,
      metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata'] as Map) : {},
    );
  }
}
