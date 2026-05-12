class SyncLog {
  final String id;
  final String sender;
  final String? otp;
  final String message;
  final DateTime timestamp;
  final bool isSynced;
  final String? errorMessage;

  SyncLog({
    required this.id,
    required this.sender,
    this.otp,
    required this.message,
    required this.timestamp,
    this.isSynced = false,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'sender': sender,
    'otp': otp,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'isSynced': isSynced,
    'errorMessage': errorMessage,
  };

  factory SyncLog.fromJson(Map<String, dynamic> json) => SyncLog(
    id: json['id'] as String,
    sender: json['sender'] as String,
    otp: json['otp'] as String?,
    message: json['message'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    isSynced: json['isSynced'] as bool? ?? false,
    errorMessage: json['errorMessage'] as String?,
  );

  SyncLog copyWith({
    String? id,
    String? sender,
    String? otp,
    String? message,
    DateTime? timestamp,
    bool? isSynced,
    String? errorMessage,
  }) =>
      SyncLog(
        id: id ?? this.id,
        sender: sender ?? this.sender,
        otp: otp ?? this.otp,
        message: message ?? this.message,
        timestamp: timestamp ?? this.timestamp,
        isSynced: isSynced ?? this.isSynced,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
