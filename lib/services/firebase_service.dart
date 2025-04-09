import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';

class FirebaseService with ChangeNotifier {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger('FirebaseService');
  
  bool _isConnected = false;
  String _lastError = '';
  Map<String, dynamic> _sensorData = {};
  List<Map<String, dynamic>> _dataHistory = [];
  StreamSubscription? _databaseSubscription;

  // Getters
  bool get isConnected => _isConnected;
  String get lastError => _lastError;
  Map<String, dynamic> get currentData => _sensorData;
  List<Map<String, dynamic>> get dataHistory => _dataHistory;

  FirebaseService() {
    _initializeConnection();
  }

  Future<void> _initializeConnection() async {
    try {
      // Tenter une authentification anonyme
      _logger.info('Tentative d\'authentification anonyme...');
      try {
        await _auth.signInAnonymously();
        _logger.info('Authentification anonyme réussie ✅');
      } catch (authError) {
        _logger.warning('Authentification anonyme échouée, tentative de connexion sans authentification: $authError');
        // Continue même si l'authentification échoue (ça peut fonctionner si les règles de sécurité permettent l'accès public)
      }
      
      // Configurer la référence à la base de données de ESP32-MOHA
      final databaseRef = _database.ref();
      
      _logger.info('Tentative de connexion à Firebase Realtime Database (ESP32-MOHA)...');
      
      // Vérifier la connexion
      final connectionRef = _database.ref('.info/connected');
      connectionRef.onValue.listen((event) {
        _isConnected = event.snapshot.value as bool? ?? false;
        _logger.info('État de connexion Firebase: ${_isConnected ? 'Connecté ✅' : 'Déconnecté ❌'}');
        notifyListeners();
      });

      // S'abonner aux changements de données
      _subscribeToDataChanges(databaseRef);
      
      // Si connecté, essayer de récupérer les données immédiatement
      if (_auth.currentUser != null || true) { // Tenter même sans authentification
        await fetchHistoricalData();
      }
      
    } catch (e) {
      _isConnected = false;
      _lastError = e.toString();
      _logger.severe('Erreur de connexion à Firebase: $e');
      notifyListeners();
    }
  }

  void _subscribeToDataChanges(DatabaseReference ref) {
    // Annuler l'abonnement existant s'il y en a un
    _databaseSubscription?.cancel();
    
    try {
      // Essayer d'abord de récupérer uniquement le nœud DHT11
      _databaseSubscription = ref.child('DHT11').onValue.listen((event) {
        if (event.snapshot.value != null) {
          final dynamic data = event.snapshot.value;
          
          if (data is Map) {
            _sensorData = {'DHT11': Map<String, dynamic>.from(data)};
            
            // Ajouter les données à l'historique avec un timestamp
            _dataHistory.insert(0, {
              ..._sensorData,
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            });
            
            // Limiter l'historique à 100 entrées pour éviter d'utiliser trop de mémoire
            if (_dataHistory.length > 100) {
              _dataHistory = _dataHistory.sublist(0, 100);
            }
            
            _logger.info('Données reçues pour DHT11: $data');
            notifyListeners();
          }
        }
      }, onError: (error) {
        _lastError = 'Erreur lors de la récupération des données DHT11: $error. Vérifiez les règles de sécurité Firebase.';
        _logger.severe(_lastError);
        notifyListeners();
      });
      
      _logger.info('Abonnement aux données réussi');
    } catch (e) {
      _lastError = 'Erreur lors de l\'abonnement aux données: $e. Vérifiez les règles de sécurité Firebase et l\'accès réseau.';
      _logger.severe(_lastError);
      notifyListeners();
    }
  }

  // Méthode pour récupérer l'historique des données depuis Firebase
  Future<void> fetchHistoricalData({int limitToLast = 50}) async {
    try {
      // Pointer vers DHT11 pour l'historique
      final historyRef = _database.ref().child("DHT11");
      final snapshot = await historyRef.get();
      
      if (snapshot.exists) {
        final dynamic data = snapshot.value;
        
        if (data is Map) {
          final historyList = <Map<String, dynamic>>[];
          
          // Ajouter les données actuelles à l'historique
          historyList.add({
            'DHT11': Map<String, dynamic>.from(data),
            'id': 'current',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
          
          _dataHistory = historyList;
          _logger.info('Données historiques récupérées: ${data.length} entrées');
          notifyListeners();
        }
      } else {
        _logger.warning('Aucune donnée historique trouvée. Noeud DHT11 inexistant ou inaccessible.');
      }
    } catch (e) {
      _lastError = 'Erreur lors de la récupération des données historiques: $e. Vérifiez les règles de sécurité Firebase.';
      _logger.severe(_lastError);
      notifyListeners();
    }
  }

  // Méthode de test pour vérifier la connexion à Firebase
  Future<bool> testConnection() async {
    try {
      // Utiliser une référence valide pour tester la connexion
      final testRef = _database.ref('.info/connected');
      final snapshot = await testRef.get();
      _isConnected = snapshot.value as bool? ?? false;
      
      // Si nous sommes connectés, essayons de lire les données DHT11
      if (_isConnected) {
        try {
          final dht11Ref = _database.ref('DHT11');
          final dht11Snapshot = await dht11Ref.get();
          if (dht11Snapshot.exists) {
            _logger.info('Test de connexion DHT11: Succès ✅ - Données: ${dht11Snapshot.value}');
          } else {
            _logger.warning('Test de connexion DHT11: Nœud trouvé mais sans données');
          }
        } catch (dht11Error) {
          _logger.warning('Test de lecture DHT11: $dht11Error');
        }
      }
      
      _logger.info('Test de connexion Firebase: ${_isConnected ? 'Succès ✅' : 'Échec ❌'}');
      notifyListeners();
      return _isConnected;
    } catch (e) {
      _isConnected = false;
      _lastError = 'Erreur de test de connexion: $e';
      _logger.severe(_lastError);
      notifyListeners();
      return false;
    }
  }

  // Envoyer des données à Firebase (si nécessaire)
  Future<void> sendCommand(String command, dynamic value) async {
    try {
      await _database.ref().child("commands").update({
        command: value,
        'timestamp': ServerValue.timestamp,
      });
      _logger.info('Commande envoyée: $command = $value');
    } catch (e) {
      _lastError = e.toString();
      _logger.severe('Erreur lors de l\'envoi de la commande: $e');
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _databaseSubscription?.cancel();
    super.dispose();
  }
} 