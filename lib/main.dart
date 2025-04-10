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
  
  // Configuration du logger - désactivé en production
  Logger.root.level = Level.INFO; // Réduire le niveau par rapport à ALL pour limiter le debug
  Logger.root.onRecord.listen((record) {
    // Afficher uniquement les messages WARNING et ERROR en production
    if (record.level.value >= Level.WARNING.value) {
      debugPrint('${record.level.name}: ${record.message}');
    }
  });
  
  final logger = Logger('IoTApp');
  
  // Vérification des clés API - messages moins verbeux
  if (!ApiKeys.isConfigured) {
    logger.warning('⚠️ ${ApiKeys.getMissingKeysMessage()}');
  }
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    logger.info('Firebase initialisé');
  } catch (e) {
    logger.severe('Erreur Firebase: $e');
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
            debugShowCheckedModeBanner: false, // Supprimer le banner de debug
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
