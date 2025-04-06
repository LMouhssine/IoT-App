import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  
  // Identifiants temporaires pour la démonstration
  static const String demoEmail = 'demo@iot.app';
  static const String demoPassword = 'iot123456';
  bool _isDemoUser = false;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoggedIn => _user != null || _isDemoUser;
  bool get isDemoUser => _isDemoUser;

  Future<bool> signIn(String email, String password) async {
    // Vérification des identifiants temporaires
    if (email == demoEmail && password == demoPassword) {
      _isDemoUser = true;
      notifyListeners();
      return true;
    }
    
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      debugPrint('Error signing in: $e');
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      debugPrint('Error signing up: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    if (_isDemoUser) {
      _isDemoUser = false;
      notifyListeners();
      return;
    }
    
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }
}