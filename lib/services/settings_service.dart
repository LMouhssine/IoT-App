import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService with ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isDarkMode = false;
  String _language = 'Français';
  String _temperatureUnit = '°C';
  double _threshold = 25.0;
  bool _notificationsEnabled = true;
  bool _emailAlertsEnabled = false;

  bool get isDarkMode => _isDarkMode;
  String get language => _language;
  String get temperatureUnit => _temperatureUnit;
  double get threshold => _threshold;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get emailAlertsEnabled => _emailAlertsEnabled;
  
  // Pour la compatibilité avec le code existant
  String get selectedLanguage => _language;
  String get selectedUnit => _temperatureUnit;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
  }

  void _loadSettings() {
    _isDarkMode = _prefs.getBool('isDarkMode') ?? false;
    _language = _prefs.getString('language') ?? 'Français';
    _temperatureUnit = _prefs.getString('temperatureUnit') ?? '°C';
    _threshold = _prefs.getDouble('threshold') ?? 25.0;
    _notificationsEnabled = _prefs.getBool('notificationsEnabled') ?? true;
    _emailAlertsEnabled = _prefs.getBool('emailAlertsEnabled') ?? false;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }
  
  // Pour la compatibilité avec le code existant
  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _prefs.setBool('isDarkMode', value);
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _language = language;
    await _prefs.setString('language', language);
    notifyListeners();
  }

  Future<void> setTemperatureUnit(String unit) async {
    _temperatureUnit = unit;
    await _prefs.setString('temperatureUnit', unit);
    notifyListeners();
  }
  
  // Pour la compatibilité avec le code existant
  Future<void> setUnit(String value) async {
    _temperatureUnit = value;
    await _prefs.setString('temperatureUnit', value);
    notifyListeners();
  }

  Future<void> setThreshold(double value) async {
    _threshold = value;
    await _prefs.setDouble('threshold', value);
    notifyListeners();
  }
  
  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    await _prefs.setBool('notificationsEnabled', value);
    notifyListeners();
  }
  
  Future<void> setEmailAlertsEnabled(bool value) async {
    _emailAlertsEnabled = value;
    await _prefs.setBool('emailAlertsEnabled', value);
    notifyListeners();
  }
} 