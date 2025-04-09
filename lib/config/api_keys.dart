/// Class pour gérer les clés API de façon sécurisée
/// 
/// Les clés API sont fournies via des variables d'environnement
/// lors de la compilation (--dart-define) et jamais stockées
/// directement dans le code source.
class ApiKeys {
  /// Firebase API Key
  /// 
  /// Cette clé est utilisée pour l'authentification Firebase
  /// Pour la définir, utilisez: --dart-define=FIREBASE_API_KEY=votre_clé
  static const String firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'AIzaSyDemoKeyForTesting',
  );
  
  /// Firebase Database URL
  /// 
  /// Cette URL est utilisée pour se connecter à Firebase Realtime Database
  /// Pour la définir, utilisez: --dart-define=FIREBASE_DB_URL=votre_url
  static const String firebaseDatabaseUrl = String.fromEnvironment(
    'FIREBASE_DB_URL',
    defaultValue: 'https://iot-app-demo.firebaseio.com',
  );
  
  /// Vérifie si les clés API nécessaires sont configurées
  static bool get isConfigured {
    return firebaseApiKey != 'FIREBASE_API_KEY_NOT_SET' &&
           firebaseDatabaseUrl != 'FIREBASE_DB_URL_NOT_SET';
  }
  
  /// Affiche un message d'erreur si les clés API ne sont pas configurées
  static String getMissingKeysMessage() {
    final List<String> missingKeys = [];
    
    if (firebaseApiKey == 'FIREBASE_API_KEY_NOT_SET') {
      missingKeys.add('FIREBASE_API_KEY');
    }
    
    if (firebaseDatabaseUrl == 'FIREBASE_DB_URL_NOT_SET') {
      missingKeys.add('FIREBASE_DB_URL');
    }
    
    if (missingKeys.isEmpty) {
      return 'Toutes les clés API sont configurées.';
    }
    
    return 'Les clés API suivantes ne sont pas configurées: ${missingKeys.join(', ')}.\n'
           'Utilisez --dart-define pour les configurer lors de la compilation.';
  }
} 