import 'package:flutter/material.dart';
import '../models/otp_message.dart';
import '../models/app_settings.dart';
import '../services/settings_service.dart';
import '../services/sms_listener_service.dart';

class AppProvider extends ChangeNotifier {
  final SettingsService _settingsService;
  late final SmsListenerService _smsListenerService;

  AppSettings _settings = AppSettings(backendUrl: '', isEnabled: false);
  List<OtpMessage> _otpHistory = [];
  bool _isLoading = false;
  String? _error;

  AppProvider({required SettingsService settingsService})
      : _settingsService = settingsService;

  // Getters
  AppSettings get settings => _settings;
  List<OtpMessage> get otpHistory => _otpHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      _settings = await _settingsService.getSettings();

      _smsListenerService = SmsListenerService(settingsService: _settingsService);
      await _smsListenerService.initialize();

      // Listen to OTP messages
      _smsListenerService.otpMessageStream.listen((otpMessage) {
        _otpHistory.insert(0, otpMessage);
        notifyListeners();
      });

      _error = null;
    } catch (e) {
      _error = 'Initialization error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setBackendUrl(String url) async {
    try {
      _error = null;
      await _settingsService.setBackendUrl(url);
      _settings = _settings.copyWith(backendUrl: url);
      notifyListeners();
    } catch (e) {
      _error = 'Error setting backend URL: $e';
      notifyListeners();
    }
  }

  Future<void> setEnabled(bool isEnabled) async {
    try {
      _error = null;
      await _settingsService.setEnabled(isEnabled);
      _settings = _settings.copyWith(isEnabled: isEnabled);
      notifyListeners();
    } catch (e) {
      _error = 'Error updating setting: $e';
      notifyListeners();
    }
  }

  Future<void> loadSettings() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _settings = await _settingsService.getSettings();
    } catch (e) {
      _error = 'Error loading settings: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearOtpHistory() {
    _otpHistory.clear();
    notifyListeners();
  }

  void removeOtpMessage(int index) {
    if (index >= 0 && index < _otpHistory.length) {
      _otpHistory.removeAt(index);
      notifyListeners();
    }
  }

  @override
  Future<void> dispose() async {
    await _smsListenerService.dispose();
    super.dispose();
  }
}
