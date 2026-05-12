import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

class SettingsService {
  static const String _backendUrlKey = 'backend_url';
  static const String _isEnabledKey = 'is_enabled';

  SharedPreferences? _prefs;

  /// Ensures SharedPreferences is initialized before use
  Future<SharedPreferences> get _storage async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<AppSettings> getSettings() async {
    final prefs = await _storage;
    return AppSettings(
      backendUrl: prefs.getString(_backendUrlKey) ?? '',
      isEnabled: prefs.getBool(_isEnabledKey) ?? false,
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await _storage;
    await Future.wait([
      prefs.setString(_backendUrlKey, settings.backendUrl),
      prefs.setBool(_isEnabledKey, settings.isEnabled),
    ]);
  }

  Future<void> setBackendUrl(String url) async {
    final prefs = await _storage;
    await prefs.setString(_backendUrlKey, url);
  }

  Future<void> setEnabled(bool isEnabled) async {
    final prefs = await _storage;
    await prefs.setBool(_isEnabledKey, isEnabled);
  }

  Future<String> getBackendUrl() async {
    final prefs = await _storage;
    return prefs.getString(_backendUrlKey) ?? '';
  }

  Future<bool> isEnabled() async {
    final prefs = await _storage;
    return prefs.getBool(_isEnabledKey) ?? false;
  }
}