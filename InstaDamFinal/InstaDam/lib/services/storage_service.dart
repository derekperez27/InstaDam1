import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  SharedPreferences? _prefs;

  StorageService._internal();
  factory StorageService() => _instance;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Remembered user
  Future<void> setRememberedUser(String username) async {
    await _prefs?.setString('remembered_user', username);
  }

  String? getRememberedUser() => _prefs?.getString('remembered_user');

  Future<void> clearRememberedUser() async {
    await _prefs?.remove('remembered_user');
  }

  // Theme
  Future<void> setDarkMode(bool isDark) async => await _prefs?.setBool('is_dark', isDark);
  bool getDarkMode() => _prefs?.getBool('is_dark') ?? false;

  // Language
  Future<void> setLanguage(String code) async => await _prefs?.setString('language', code);
  String getLanguage() => _prefs?.getString('language') ?? 'en';

  // Notifications (simulated)
  Future<void> setNotificationsEnabled(bool enabled) async => await _prefs?.setBool('notifications_enabled', enabled);
  bool getNotificationsEnabled() => _prefs?.getBool('notifications_enabled') ?? true;

  // Profile fields
  Future<void> setProfileName(String name) async => await _prefs?.setString('profile_name', name);
  String? getProfileName() => _prefs?.getString('profile_name');

  Future<void> clearAll() async => await _prefs?.clear();
}
