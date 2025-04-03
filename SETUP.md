# Guide de configuration sécurisée des clés API

Ce document explique comment configurer correctement les clés API pour ce projet sans compromettre leur sécurité.

## Étape 1: Obtenir les clés API Firebase

1. Créez un projet sur la [console Firebase](https://console.firebase.google.com/)
2. Ajoutez une application Android (package: com.example.iot_app)
3. Téléchargez le fichier `google-services.json`

## Étape 2: Configuration du projet

1. Copiez le fichier `google-services.json.example` vers `google-services.json` dans le dossier `android/app/`
2. Remplacez les valeurs de l'exemple par vos propres valeurs obtenues de Firebase
3. **Ne committez jamais** ce fichier avec vos clés réelles

## Étape 3: Configuration des variables d'environnement

Pour exécuter l'application en mode développement:

```bash
flutter run --dart-define=FIREBASE_API_KEY=votre_clé_api
```

Pour le build de production:

```bash
flutter build apk --dart-define=FIREBASE_API_KEY=votre_clé_api
```

## Étape 4: Configuration CI/CD (optionnel)

Si vous utilisez GitHub Actions ou un autre service CI/CD, stockez la clé API en tant que secret:

1. Dans votre dépôt GitHub, allez dans Settings > Secrets > Actions
2. Ajoutez un nouveau secret appelé `FIREBASE_API_KEY` avec votre clé
3. Dans votre workflow, utilisez:

```yaml
- name: Build and Release
  run: flutter build apk --dart-define=FIREBASE_API_KEY=${{ secrets.FIREBASE_API_KEY }}
```

## Vérification de la configuration

Pour vérifier que vos clés API sont correctement configurées:

1. Exécutez l'application
2. Vérifiez les logs au démarrage - vous devriez voir "Toutes les clés API sont configurées"
3. Si vous voyez un avertissement, cela signifie que certaines clés API ne sont pas configurées correctement

## Bonnes pratiques de sécurité

- Ne stockez jamais les clés API dans le code source
- Utilisez toujours des variables d'environnement ou des secrets CI/CD
- Utilisez la classe `ApiKeys` pour accéder aux clés de manière sécurisée
- Vérifiez régulièrement les alertes de sécurité pour détecter d'éventuelles fuites 