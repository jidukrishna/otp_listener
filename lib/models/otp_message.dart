class OtpMessage {
  final String sender;
  final String message;
  final String? otp;
  final DateTime timestamp;

  OtpMessage({
    required this.sender,
    required this.message,
    this.otp,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'sender': sender,
    'message': message,
    'otp': otp,
    'timestamp': timestamp.toIso8601String(),
  };

  factory OtpMessage.fromJson(Map<String, dynamic> json) => OtpMessage(
    sender: json['sender'] as String,
    message: json['message'] as String,
    otp: json['otp'] as String?,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}
