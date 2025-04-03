class AppConstants {
  // App Info
  static const String appName = 'IoT Temperature Monitor';
  static const String appVersion = '1.0.0';

  // Languages
  static const List<String> supportedLanguages = ['Français', 'English', 'Español'];
  static const String defaultLanguage = 'Français';

  // Temperature Units
  static const List<String> temperatureUnits = ['°C', '°F'];
  static const String defaultUnit = '°C';

  // Default Values
  static const double defaultThreshold = 25.0;
  static const double minThreshold = 0.0;
  static const double maxThreshold = 50.0;

  // Routes
  static const String homeRoute = '/home';
  static const String settingsRoute = '/settings';
  static const String thresholdRoute = '/threshold';
  static const String historyRoute = '/history';
} 