import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final SharedPreferences _prefs;
  
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  
  AuthService._internal() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _saveUserData(credential.user);
      return credential;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _saveUserData(credential.user);
      return credential;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _clearUserData();
  }

  Future<void> _saveUserData(User? user) async {
    if (user != null) {
      await _prefs.setString('userId', user.uid);
      await _prefs.setString('userEmail', user.email ?? '');
    }
  }

  Future<void> _clearUserData() async {
    await _prefs.remove('userId');
    await _prefs.remove('userEmail');
  }

  User? get currentUser => _auth.currentUser;
  
  bool get isAuthenticated => _auth.currentUser != null;
}