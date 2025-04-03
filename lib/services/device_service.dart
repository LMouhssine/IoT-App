import 'dart:async';
import 'package:flutter/foundation.dart';

class DeviceService with ChangeNotifier {
  double _temperature = 25.0;
  int _humidity = 60;
  List<Map<String, dynamic>> _history = [];
  Timer? _timer;

  DeviceService() {
    // Simuler les mises à jour de données en temps réel
    _startDataSimulation();
    // Générer un historique initial
    _generateHistory();
  }

  double get temperature => _temperature;
  int get humidity => _humidity;
  List<Map<String, dynamic>> get history => _history;

  void _startDataSimulation() {
    // Simuler des changements de données toutes les 5 secondes
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // Simuler des fluctuations aléatoires
      _temperature = 20 + (DateTime.now().millisecondsSinceEpoch % 100) / 10;
      _humidity = 50 + (DateTime.now().millisecondsSinceEpoch % 200) ~/ 10;
      
      // Ajouter à l'historique
      _history.insert(0, {
        'temperature': _temperature,
        'humidity': _humidity,
        'timestamp': DateTime.now(),
      });
      
      // Limiter l'historique à 100 entrées
      if (_history.length > 100) {
        _history = _history.sublist(0, 100);
      }
      
      notifyListeners();
    });
  }

  void _generateHistory() {
    final now = DateTime.now();
    _history = List.generate(50, (index) {
      return {
        'temperature': 20 + (index % 10) + (index % 3) * 0.1,
        'humidity': 50 + (index % 20),
        'timestamp': now.subtract(Duration(minutes: index * 5)),
      };
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
} 