import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/settings_service.dart';
import '../constants.dart';
import '../services/firebase_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthService>().signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            'Apparence',
            [
              SwitchListTile(
                title: const Text('Mode sombre'),
                subtitle: const Text('Activer le thème sombre'),
                value: settings.isDarkMode,
                onChanged: (value) => settings.setDarkMode(value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            'Notifications',
            [
              SwitchListTile(
                title: const Text('Notifications push'),
                subtitle: const Text('Recevoir des notifications sur les événements'),
                value: settings.notificationsEnabled,
                onChanged: (value) => settings.setNotificationsEnabled(value),
              ),
              SwitchListTile(
                title: const Text('Alertes par email'),
                subtitle: const Text('Recevoir des alertes par email'),
                value: settings.emailAlertsEnabled,
                onChanged: (value) => settings.setEmailAlertsEnabled(value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            'Préférences',
            [
              ListTile(
                title: const Text('Langue'),
                subtitle: Text(settings.selectedLanguage),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showLanguageDialog(context, settings),
              ),
              ListTile(
                title: const Text('Unité de température'),
                subtitle: Text(settings.selectedUnit),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showUnitDialog(context, settings),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFirebaseDiagnosticSection(context),
          const SizedBox(height: 16),
          _buildSection(
            context,
            'À propos',
            [
              const ListTile(
                title: Text('Version'),
                subtitle: Text(AppConstants.appVersion),
                leading: Icon(Icons.info),
              ),
              ListTile(
                title: const Text('Conditions d\'utilisation'),
                leading: const Icon(Icons.description),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigation vers les conditions d'utilisation
                },
              ),
              ListTile(
                title: const Text('Politique de confidentialité'),
                leading: const Icon(Icons.privacy_tip),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigation vers la politique de confidentialité
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsService settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppConstants.supportedLanguages.map((language) {
            return RadioListTile<String>(
              title: Text(language),
              value: language,
              groupValue: settings.selectedLanguage,
              onChanged: (value) {
                if (value != null) {
                  settings.setLanguage(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showUnitDialog(BuildContext context, SettingsService settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir l\'unité'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppConstants.temperatureUnits.map((unit) {
            return RadioListTile<String>(
              title: Text(unit),
              value: unit,
              groupValue: settings.selectedUnit,
              onChanged: (value) {
                if (value != null) {
                  settings.setUnit(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFirebaseDiagnosticSection(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Diagnostic Firebase',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // État de connexion
            ListTile(
              leading: Icon(
                firebaseService.isConnected ? Icons.check_circle : Icons.error,
                color: firebaseService.isConnected ? Colors.green : Colors.red,
              ),
              title: const Text('État de connexion'),
              subtitle: Text(
                firebaseService.isConnected ? 'Connecté' : 'Déconnecté',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => firebaseService.testConnection(),
              ),
            ),
            
            // Authentification
            ListTile(
              leading: Icon(
                FirebaseAuth.instance.currentUser != null ? Icons.person : Icons.person_off,
                color: FirebaseAuth.instance.currentUser != null ? Colors.green : Colors.orange,
              ),
              title: const Text('Authentification'),
              subtitle: Text(
                FirebaseAuth.instance.currentUser != null 
                    ? 'Authentifié: ${FirebaseAuth.instance.currentUser!.isAnonymous ? 'Anonyme' : 'Utilisateur'}'
                    : 'Non authentifié',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.login),
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signInAnonymously();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Authentification anonyme réussie')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur d\'authentification: $e')),
                      );
                    }
                  }
                },
              ),
            ),
            
            // URL de la base de données
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('URL de la base de données'),
              subtitle: const Text('https://esp32-moha-default-rtdb.europe-west1.firebasedatabase.app'),
            ),
            
            // Dernière erreur
            if (firebaseService.lastError.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.warning, color: Colors.orange),
                title: const Text('Dernière erreur'),
                subtitle: Text(firebaseService.lastError),
              ),
              
            // Test de lecture directe
            ElevatedButton(
              onPressed: () async {
                try {
                  final snapshot = await FirebaseDatabase.instance.ref('DHT11').get();
                  final message = snapshot.exists 
                      ? 'Lecture réussie: ${snapshot.value}' 
                      : 'Nœud DHT11 non trouvé';
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur de lecture: $e')),
                    );
                  }
                }
              },
              child: const Text('Tester la lecture depuis DHT11'),
            ),
          ],
        ),
      ),
    );
  }
} 