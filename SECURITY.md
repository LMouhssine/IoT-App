# Actions à prendre après avoir exposé des clés API

Si vous découvrez que des clés API ont été exposées dans le dépôt Git, suivez ces étapes immédiatement:

## 1. Révoquer et remplacer les clés exposées

- Connectez-vous à la [console Firebase](https://console.firebase.google.com/)
- Allez dans les paramètres du projet > Général
- Cliquez sur "Ajouter une application" ou modifiez l'application existante 
- Régénérez les clés API ou les secrets exposés
- Mettez à jour vos environnements de développement et de production avec les nouvelles clés

## 2. Corriger le code

- Assurez-vous que les clés API sont stockées en dehors du code source
- Utilisez des variables d'environnement avec `--dart-define=KEY=VALUE`
- Utilisez la classe `ApiKeys` pour récupérer les clés de manière sécurisée
- Vérifiez que les fichiers sensibles sont dans `.gitignore`

## 3. Informer l'équipe

- Avertissez tous les membres de l'équipe de l'incident
- Demandez-leur de mettre à jour leurs environnements de développement
- Assurez-vous que tout le monde comprend le nouveau processus de gestion des clés API

## 4. Surveiller l'activité

- Surveillez l'utilisation des anciennes clés API pour détecter toute utilisation abusive
- Configurez des alertes sur les plateformes concernées

## Bonnes pratiques pour éviter l'exposition de clés API

- Traitez les clés API et les secrets comme des mots de passe
- N'incluez jamais de clés API ou de secrets dans le code source
- Utilisez des fichiers d'exemple (.example) pour les fichiers de configuration
- Utilisez des variables d'environnement et des outils comme `--dart-define`
- Configurez une analyse de sécurité dans votre CI/CD
- Testez régulièrement avec des scanners de secrets 