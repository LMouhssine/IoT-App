import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../constants.dart';

class ThresholdScreen extends StatefulWidget {
  const ThresholdScreen({super.key});

  @override
  ThresholdScreenState createState() => ThresholdScreenState();
}

class ThresholdScreenState extends State<ThresholdScreen> {
  final _formKey = GlobalKey<FormState>();
  late double _threshold;

  @override
  void initState() {
    super.initState();
    // Initialiser avec la valeur du service
    _threshold = Provider.of<SettingsService>(context, listen: false).threshold;
  }

  @override
  Widget build(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Set Threshold')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Current threshold: ${_threshold.toStringAsFixed(1)}°C',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Slider(
                min: AppConstants.minThreshold,
                max: AppConstants.maxThreshold,
                value: _threshold,
                onChanged: (value) => setState(() => _threshold = value),
                divisions: 50,
                label: '${_threshold.toStringAsFixed(1)}°C',
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  settingsService.setThreshold(_threshold);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Threshold set to ${_threshold.toStringAsFixed(1)}°C'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Save Threshold'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}