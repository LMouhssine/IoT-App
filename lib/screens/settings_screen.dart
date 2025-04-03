import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/settings_service.dart';
import '../constants.dart';

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
            onPressed: () => context.read<AuthService>().signOut(),
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
} 