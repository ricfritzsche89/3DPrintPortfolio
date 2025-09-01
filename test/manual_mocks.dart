import 'dart:async';
import 'dart:io';
import 'package:ddd_druck_katalog/models/eintrag.dart';
import 'package:ddd_druck_katalog/models/kommentar.dart';
import 'package:ddd_druck_katalog/services/auth_service.dart';
import 'package:ddd_druck_katalog/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// --- Mock AuthService ---
class MockAuthService with ChangeNotifier implements AuthService {
  bool _isAdmin = false;
  User? _user;

  @override
  bool get isAdmin => _isAdmin;

  @override
  String? get userId => _isAdmin ? 'admin-uid' : 'anonymous-uid';

  @override
  User? get user => _user;

  @override
  Future<String?> signIn({required String username, required String password}) async {
    if (username == 'Ric89' && password == 'Nadineundric22') {
      _isAdmin = true;
      notifyListeners();
      return null;
    }
    return 'Falsche Anmeldedaten';
  }

  @override
  Future<void> signOut() async {
    _isAdmin = false;
    notifyListeners();
  }

  // Nicht implementiert für den Test, da nicht benötigt
  @override
  bool get isLoading => false;
  @override
  Future<void> signInAnonymously() async {}
}


// --- Mock FirebaseService ---
class MockFirebaseService implements FirebaseService {
  final List<Eintrag> eintraege = [];
  final Map<String, List<Kommentar>> kommentare = {};

  final StreamController<List<Eintrag>> _eintraegeController = StreamController.broadcast();

  MockFirebaseService() {
    // Startdaten hinzufügen
    final testEintrag = Eintrag(
      id: 'test-1',
      titel: 'Bestehender Eintrag',
      beschreibung: 'Dies ist ein Testeintrag.',
      kategorie: 'Test',
      preis: 9.99,
      bildUrl: 'https://example.com/image.png',
      erstelltAm: DateTime.now(),
    );
    eintraege.add(testEintrag);
    _eintraegeController.add(eintraege);
  }

  @override
  Stream<List<Eintrag>> getEintraege() {
    return _eintraegeController.stream;
  }

  @override
  Future<void> addEintrag(Eintrag eintrag, File imageFile) async {
    final newEintrag = Eintrag(
      id: 'new-${DateTime.now().millisecondsSinceEpoch}',
      titel: eintrag.titel,
      beschreibung: eintrag.beschreibung,
      kategorie: eintrag.kategorie,
      preis: eintrag.preis,
      bildUrl: 'https://example.com/new_image.png',
      erstelltAm: DateTime.now(),
    );
    eintraege.add(newEintrag);
    _eintraegeController.add(List.from(eintraege));
  }

  @override
  Future<void> updateEintrag(Eintrag eintrag, {File? newImageFile}) async {
    final index = eintraege.indexWhere((e) => e.id == eintrag.id);
    if (index != -1) {
      eintraege[index] = eintrag;
      _eintraegeController.add(List.from(eintraege));
    }
  }

  @override
  Future<void> deleteEintrag(String eintragId, String bildUrl) async {
    eintraege.removeWhere((e) => e.id == eintragId);
    _eintraegeController.add(List.from(eintraege));
  }

  // --- Andere Methoden als leere Stubs ---
  @override
  Future<String> uploadImage(String eintragId, File imageFile) async => 'https://example.com/mock.png';
  @override
  Future<void> deleteImage(String bildUrl) async {}
  @override
  Stream<List<Kommentar>> getKommentare(String eintragId) => Stream.value([]);
  @override
  Future<void> addKommentar(String eintragId, Kommentar kommentar) async {}
  @override
  Future<void> deleteKommentar(String eintragId, String kommentarId) async {}
  @override
  Future<void> toggleVormerkung(String eintragId, String userId, bool hatBereitsVorgemerkt) async {}
  @override
  Stream<List<Eintrag>> getMeineVormerkungen(String userId) => Stream.value([]);
  @override
  Stream<bool> hatVorgemerkt(String eintragId, String userId) => Stream.value(false);
  @override
  Stream<int> getVormerkungenCount(String eintragId) => Stream.value(0);
}
