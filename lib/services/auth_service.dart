import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoading = false;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
    // Beim Start versuchen, anonym anzumelden, falls niemand angemeldet ist.
    signInAnonymously();
  }

  User? get user => _user;
  String? get userId => _user?.uid;
  bool get isLoading => _isLoading;
  // Der Admin ist derjenige, der nicht anonym ist.
  bool get isAdmin => _user != null && !_user!.isAnonymous;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    if (user == null) {
      // Wenn der User sich ausloggt (auch der anonyme), sofort neuen anonymen User erstellen.
      await signInAnonymously();
    }
    notifyListeners();
  }

  // Anonyme Anmeldung
  Future<void> signInAnonymously() async {
    if (_auth.currentUser == null) {
      try {
        await _auth.signInAnonymously();
      } catch (e) {
        print("Fehler bei anonymer Anmeldung: $e");
      }
    }
  }

  // Admin-Anmeldefunktion
  Future<String?> signIn({required String username, required String password}) async {
    _setLoading(true);
    try {
      String email = '$username@druckkatalog.app';
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _setLoading(false);
      return null; // Erfolgreich
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'Benutzername oder Passwort ist falsch.';
      }
      return 'Ein unbekannter Fehler ist aufgetreten.';
    } catch (e) {
      _setLoading(false);
      return 'Ein Fehler ist aufgetreten: ${e.toString()}';
    }
  }

  // Abmeldefunktion (nur für Admin)
  Future<void> signOut() async {
    // Wenn der Admin sich ausloggt, wird der authStateChanges-Listener
    // automatisch eine neue anonyme Sitzung starten.
    await _auth.signOut();
  }
}
