import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/auth_service.dart';
import 'services/device_service.dart';
import 'services/settings_service.dart';
import 'services/firebase_service.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/history_screen.dart';
import 'screens/threshold_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';
import 'constants.dart';
import 'firebase_options.dart';
import 'config/api_keys.dart';
import 'package:logging/logging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configuration du logger
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // Don't use print in production code
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });
  
  final logger = Logger('IoTApp');
  
  // Vérification des clés API
  logger.info('Vérification des clés API...');
  if (!ApiKeys.isConfigured) {
    logger.warning('⚠️ ATTENTION: ${ApiKeys.getMissingKeysMessage()}');
  }
  
  try {
    logger.info('Initialisation de Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    logger.info('Firebase initialisé avec succès ✅');
  } catch (e) {
    logger.severe('Erreur lors de l\'initialisation de Firebase: $e');
  }
  
  final settingsService = SettingsService();
  await settingsService.init();
  
  runApp(MyApp(settingsService: settingsService));
}

class MyApp extends StatelessWidget {
  final SettingsService settingsService;
  
  const MyApp({super.key, required this.settingsService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider<SettingsService>.value(value: settingsService),
        ChangeNotifierProvider(create: (_) => DeviceService()),
        ChangeNotifierProvider(create: (_) => FirebaseService()),
      ],
      child: Consumer<SettingsService>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: AppConstants.appName,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: '/',
            routes: {
              '/': (context) => const AuthWrapper(),
              AppConstants.homeRoute: (context) => const HomeScreen(),
              AppConstants.thresholdRoute: (context) => const ThresholdScreen(),
              AppConstants.historyRoute: (context) => const HistoryScreen(),
              AppConstants.settingsRoute: (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, child) {
        if (auth.isLoggedIn) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
