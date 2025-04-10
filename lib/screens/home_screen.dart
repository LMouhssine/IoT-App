import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logging/logging.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../constants.dart';
import '../widgets/nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Logger _logger = Logger('HomeScreen');
  
  double temperature = 0.0;
  double humidity = 0.0;
  double threshold = 25.0;
  String unit = '°C';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialiser les données au démarrage après que le build soit terminé
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  // Méthode pour récupérer les données à la demande (rafraîchissement manuel)
  Future<void> _fetchData() async {
    if (!mounted) return; // Vérifier si le widget est toujours monté avant de commencer
    
    setState(() {
      isLoading = true;
    });
    
    try {
      // Nous allons laisser le FirebaseService s'occuper de récupérer les données
      // Les données seront accessibles via le Provider
      
      // Récupérer le seuil depuis Firebase si nécessaire
      final databaseReference = FirebaseDatabase.instance.ref();
      
      final snapshotThreshold = await databaseReference.child('settings/threshold').get();
      if (snapshotThreshold.exists && mounted) {
        final value = snapshotThreshold.value;
        if (value is double) {
          setState(() => threshold = value);
        } else if (value is int) {
          setState(() => threshold = value.toDouble());
        } else if (value is String) {
          setState(() => threshold = double.tryParse(value) ?? 25.0);
        }
      }
      
      final snapshotUnit = await databaseReference.child('settings/unit').get();
      if (snapshotUnit.exists && mounted) {
        setState(() => unit = snapshotUnit.value as String);
      }
      
    } catch (e) {
      _logger.severe('Erreur lors de la récupération des données: $e');
    } finally {
      if (mounted) { // Vérifier si le widget est toujours monté avant de mettre à jour l'état
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure the widget is mounted before using context
    if (!mounted) return Container();
    
    final firebaseService = Provider.of<FirebaseService>(context);
    
    // Récupérer les données de capteur depuis le service
    if (firebaseService.currentData.isNotEmpty) {
      if (firebaseService.currentData['DHT11'] != null) {
        // Si la structure est DHT11/Temperature et DHT11/Humidity
        final dht11Data = firebaseService.currentData['DHT11'];
        if (dht11Data is Map) {
          temperature = _parseDoubleValue(dht11Data['Temperature']) ?? temperature;
          humidity = _parseDoubleValue(dht11Data['Humidity']) ?? humidity;
        }
      } else {
        // Si la structure est à la racine avec clés temperature et humidity
        temperature = _parseDoubleValue(firebaseService.currentData['temperature']) ?? 
                     _parseDoubleValue(firebaseService.currentData['Temperature']) ?? temperature;
        
        humidity = _parseDoubleValue(firebaseService.currentData['humidity']) ?? 
                  _parseDoubleValue(firebaseService.currentData['Humidity']) ?? humidity;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final navigator = Navigator.of(context);
              await context.read<AuthService>().signOut();
              if (mounted) {
                navigator.pushReplacementNamed('/');
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // État actuel
                    Text(
                      'État actuel',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Cartes des capteurs améliorées
                    _buildSensorCards(context),
                    
                    const SizedBox(height: 24),
                    
                    // Seuil actuel
                    _buildThresholdStatus(context, threshold, unit),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: const NavBar(currentIndex: 0),
    );
  }

  Widget _buildSensorCards(BuildContext context) {
    return Column(
      children: [
        // Carte de température améliorée
        _buildMetricCard(
          context,
          'Temperature',
          '${temperature.toStringAsFixed(1)}$unit',
          Icons.thermostat,
          temperature > threshold ? Colors.red : Colors.orange,
          () => Navigator.pushNamed(context, AppConstants.thresholdRoute),
        ),
        
        // Carte d'humidité améliorée
        _buildMetricCard(
          context,
          'Humidity',
          '$humidity%',
          Icons.water_drop,
          Colors.blue,
          () => Navigator.pushNamed(context, AppConstants.historyRoute),
        ),
      ],
    );
  }

  // Méthode pour analyser les valeurs qui peuvent être de différents types
  double? _parseDoubleValue(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
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
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThresholdStatus(BuildContext context, double threshold, String unit) {
    return Card(
      color: Colors.orange.withAlpha(26),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, AppConstants.thresholdRoute),
        borderRadius: BorderRadius.circular(16),
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
              const Icon(Icons.chevron_right, color: Colors.orange),
            ],
          ),
        ),
      ),
    );
  }
}
