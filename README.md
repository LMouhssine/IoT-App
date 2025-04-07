# IoT Temperature Monitor

Une application Flutter pour surveiller la température et l'humidité de vos appareils IoT.

## Fonctionnalités

- Authentification des utilisateurs (email/mot de passe)
- Affichage en temps réel des données de température et d'humidité
- Historique des mesures avec graphiques
- Configuration des seuils d'alerte
- Préférences utilisateur (thème, langue, unités)
- Support du mode sombre

## Configuration

1. Clonez ce dépôt
2. Exécutez `flutter pub get` pour installer les dépendances
3. Configurez Firebase :
   - Créez un projet Firebase
   - Copiez le fichier `lib/firebase_options.dart.example` en `lib/firebase_options.dart`
   - Copiez le fichier `google-services.json.example` en `google-services.json`
   - Remplacez les valeurs "YOUR_..." par vos propres valeurs Firebase
   - **IMPORTANT**: Ne committez JAMAIS les fichiers `google-services.json` et `firebase_options.dart` avec vos clés API réelles

## Configuration des clés API sécurisées

Pour protéger vos clés API, suivez ces étapes:

1. Ne stockez jamais les clés API directement dans le code source
2. Utilisez des variables d'environnement lors de la compilation
3. Pour les configurations Firebase, utilisez le fichier `lib/config/api_keys.dart` pour accéder aux clés de manière sécurisée

Exemple d'utilisation des clés API sécurisées:
```dart
// Dans votre code
import 'package:iot_app/config/api_keys.dart';

// Utilisation
final apiKey = ApiKeys.firebaseApiKey;
```

## Exécution

```bash
flutter run --dart-define=FIREBASE_API_KEY=votre_clé_api
```

## Structure du projet

```
lib/
  ├── config/           # Configuration et clés API
  ├── services/         # Services (auth, settings, device)
  ├── screens/          # Écrans de l'application
  ├── theme/            # Thèmes et styles
  ├── constants.dart    # Constantes de l'application
  ├── firebase_options.dart      # Options Firebase (non versionné)
  └── main.dart         # Point d'entrée de l'application
```

## Sécurité

Les clés API sont protégées et ne sont pas incluses dans le code source. Elles sont injectées via des variables d'environnement lors de la compilation. Les fichiers `google-services.json` et `firebase_options.dart` sont exclus du contrôle de version via le `.gitignore`.

## Technologies utilisées

- Flutter
- Firebase (Authentication, Firestore)
- Provider pour la gestion d'état
- fl_chart pour les graphiques