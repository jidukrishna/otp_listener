class AppSettings {
  final String backendUrl;
  final bool isEnabled;

  AppSettings({
    required this.backendUrl,
    required this.isEnabled,
  });

  Map<String, dynamic> toJson() => {
    'backendUrl': backendUrl,
    'isEnabled': isEnabled,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    backendUrl: json['backendUrl'] as String? ?? '',
    isEnabled: json['isEnabled'] as bool? ?? false,
  );

  AppSettings copyWith({
    String? backendUrl,
    bool? isEnabled,
  }) =>
      AppSettings(
        backendUrl: backendUrl ?? this.backendUrl,
        isEnabled: isEnabled ?? this.isEnabled,
      );
}
