import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../constants.dart';
import '../widgets/nav_bar.dart';

class ThresholdScreen extends StatefulWidget {
  const ThresholdScreen({super.key});

  @override
  ThresholdScreenState createState() => ThresholdScreenState();
}

class ThresholdScreenState extends State<ThresholdScreen> {
  final _formKey = GlobalKey<FormState>();
  late double _threshold;
  late String _unit;

  @override
  void initState() {
    super.initState();
    // Initialiser avec la valeur du service
    final settingsService = Provider.of<SettingsService>(context, listen: false);
    _threshold = settingsService.threshold;
    _unit = settingsService.temperatureUnit;
  }

  @override
  Widget build(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration du seuil'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info card
              Card(
                color: Colors.orange.withAlpha(30),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Le seuil détermine à partir de quelle température vous recevrez des alertes',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Current threshold
              Text(
                'Seuil actuel',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                '${_threshold.toStringAsFixed(1)}$_unit',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: _threshold > 30 ? Colors.red : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 32),
              
              Text(
                'Ajuster le seuil',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Min-max labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${AppConstants.minThreshold}$_unit'),
                  Text('${AppConstants.maxThreshold}$_unit'),
                ],
              ),
              
              // Slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.orange,
                  inactiveTrackColor: Colors.orange.withAlpha(50),
                  thumbColor: Colors.orange,
                  overlayColor: Colors.orange.withAlpha(30),
                ),
                child: Slider(
                  min: AppConstants.minThreshold,
                  max: AppConstants.maxThreshold,
                  value: _threshold,
                  onChanged: (value) => setState(() => _threshold = value),
                  divisions: 50,
                  label: '${_threshold.toStringAsFixed(1)}$_unit',
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Save button
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    settingsService.setThreshold(_threshold);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Seuil défini à ${_threshold.toStringAsFixed(1)}$_unit'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Enregistrer'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const NavBar(currentIndex: 1),
    );
  }
}