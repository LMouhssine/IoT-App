import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';  // Import Firebase Realtime Database
import 'package:logging/logging.dart';
import '../services/auth_service.dart';
import '../services/device_service.dart';
import '../services/settings_service.dart';
import '../constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Logger _logger = Logger('HomeScreen');
  final databaseReference = FirebaseDatabase.instance.ref();

  double temperature = 0.0;
  double humidity = 0.0;
  double threshold = 0.0;
  String unit = '°C';

  @override
  void initState() {
    super.initState();
    // Récupérer les données de la base de données
    _fetchData();
  }

  // Méthode pour récupérer les données depuis Firebase Realtime Database
  void _fetchData() {
    // Récupérer la température et l'humidité depuis Firebase
    databaseReference.child('DHT11/temperature').get().then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          temperature = snapshot.value as double;
        });
      } else {
        _logger.warning('La température n\'a pas pu être récupérée');
      }
    });

    databaseReference.child('DHT11/humidity').get().then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          humidity = snapshot.value as double;
        });
      } else {
        _logger.warning('L\'humidité n\'a pas pu être récupérée');
      }
    });

    databaseReference.child('settings/threshold').get().then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          threshold = snapshot.value as double;
        });
      } else {
        _logger.warning('Le seuil n\'a pas pu être récupéré');
      }
    });

    // Récupérer l'unité (par exemple °C ou °F)
    databaseReference.child('settings/unit').get().then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          unit = snapshot.value as String;
        });
      } else {
        _logger.warning('L\'unité n\'a pas pu être récupérée');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceService = Provider.of<DeviceService>(context);
    final settingsService = Provider.of<SettingsService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, AppConstants.settingsRoute),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthService>().signOut().then((_) {
                Navigator.pushReplacementNamed(context, '/');
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'État actuel',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildMetricCard(
              context,
              'Temperature',
              '${temperature.toStringAsFixed(1)}$unit',
              Icons.thermostat,
              temperature > threshold ? Colors.red : Colors.orange,
            ),
            _buildMetricCard(
              context,
              'Humidity',
              '$humidity%',
              Icons.water_drop,
              Colors.blue,
            ),
            const SizedBox(height: 24),
            Text(
              'Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Seuil',
                    Icons.speed,
                    Colors.green,
                    () => Navigator.pushNamed(context, AppConstants.thresholdRoute),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Historique',
                    Icons.history,
                    Colors.purple,
                    () => Navigator.pushNamed(context, AppConstants.historyRoute),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildThresholdStatus(context, threshold, unit),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(title),
        ],
      ),
    );
  }

  Widget _buildThresholdStatus(BuildContext context, double threshold, String unit) {
    return Card(
      color: Colors.orange.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seuil actuel',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${threshold.toStringAsFixed(1)}$unit',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
