import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/eintrag.dart';
import '../models/kommentar.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Cache für Einträge
  final Map<String, Eintrag> _eintragCache = {};
  final Duration _cacheDuration = const Duration(minutes: 15);

  // --- Einträge ---

  // Stream aller Einträge für die Katalogansicht
  Stream<List<Eintrag>> getEintraege() {
    // Offline-Cache-Konfiguration für Firestore
    _firestore.settings = const Settings(
      persistenceEnabled: true, // Aktiviert Offline-Persistenz
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // Maximale Cache-Größe
    );

    return _firestore
        .collection('eintraege')
        .orderBy('erstelltAm', descending: true)
        .snapshots()
        .map((snapshot) {
      final eintraege = snapshot.docs.map((doc) {
        final eintrag = Eintrag.fromSnapshot(doc);
        // Aktualisiere den Cache
        _eintragCache[eintrag.id] = eintrag;
        return eintrag;
      }).toList();
      return eintraege;
    });
  }

  // Eintrag erstellen
  Future<void> addEintrag(Eintrag eintrag, File imageFile) async {
    // Zuerst ein leeres Dokument erstellen, um eine ID zu bekommen
    DocumentReference docRef = _firestore.collection('eintraege').doc();

    // Bild mit dieser ID hochladen
    final bildUrl = await uploadImage(docRef.id, imageFile);

    // Dokument mit den vollständigen Daten (inkl. Bild-URL) erstellen
    final newEintrag = Eintrag(
      id: docRef.id,
      titel: eintrag.titel,
      beschreibung: eintrag.beschreibung,
      kategorie: eintrag.kategorie,
      preis: eintrag.preis,
      bildUrl: bildUrl,
      erstelltAm: eintrag.erstelltAm,
    );
    await docRef.set(newEintrag.toJson());
  }

  // Eintrag aktualisieren
  Future<void> updateEintrag(Eintrag eintrag, {File? newImageFile}) async {
    String newBildUrl = eintrag.bildUrl;

    if (newImageFile != null) {
      // Neues Bild hochladen
      newBildUrl = await uploadImage(eintrag.id, newImageFile);
      // Altes Bild löschen (wenn es eine gültige URL ist)
      if (eintrag.bildUrl.isNotEmpty) {
        await deleteImage(eintrag.bildUrl);
      }
    }

    final updatedEintrag = Eintrag(
      id: eintrag.id,
      titel: eintrag.titel,
      beschreibung: eintrag.beschreibung,
      kategorie: eintrag.kategorie,
      preis: eintrag.preis,
      bildUrl: newBildUrl,
      erstelltAm: eintrag.erstelltAm,
    );

    await _firestore.collection('eintraege').doc(eintrag.id).update(updatedEintrag.toJson());
  }

  // Eintrag löschen
  Future<void> deleteEintrag(String eintragId, String bildUrl) async {
    // Zuerst das Dokument löschen
    await _firestore.collection('eintraege').doc(eintragId).delete();
    // Dann das Bild löschen
    if (bildUrl.isNotEmpty) {
      await deleteImage(bildUrl);
    }
  }

  // Bild hochladen und Download-URL erhalten
  Future<String> uploadImage(String eintragId, File imageFile) async {
    final ref = _storage.ref().child('images').child('$eintragId.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  // Bild aus Storage löschen
  Future<void> deleteImage(String bildUrl) async {
    try {
      await _storage.refFromURL(bildUrl).delete();
    } catch (e) {
      // Fehler ignorieren, falls die Datei nicht existiert etc.
      print("Fehler beim Löschen des Bildes: $e");
    }
  }

  // --- Kommentare ---

  // Stream der Kommentare für einen bestimmten Eintrag
  Stream<List<Kommentar>> getKommentare(String eintragId) {
    return _firestore.collection('eintraege').doc(eintragId).collection('kommentare').orderBy('timestamp').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Kommentar.fromSnapshot(doc)).toList();
    });
  }

  // Kommentar hinzufügen
  Future<void> addKommentar(String eintragId, Kommentar kommentar) async {
    await _firestore
        .collection('eintraege')
        .doc(eintragId)
        .collection('kommentare')
        .add(kommentar.toJson());
  }

  // Kommentar löschen
  Future<void> deleteKommentar(String eintragId, String kommentarId) async {
    await _firestore
        .collection('eintraege')
        .doc(eintragId)
        .collection('kommentare')
        .doc(kommentarId)
        .delete();
  }

  // --- Vormerkungen ---

  // Vormerkung hinzufügen oder entfernen (Toggle)
  Future<void> toggleVormerkung(String eintragId, String userId, bool hatBereitsVorgemerkt) async {
    final docRef = _firestore
        .collection('eintraege')
        .doc(eintragId)
        .collection('vormerkungen')
        .doc(userId);

    if (hatBereitsVorgemerkt) {
      // Entfernen
      await docRef.delete();
    } else {
      // Hinzufügen
      await docRef.set({
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  // Stream der Vormerkungen eines Nutzers
  Stream<List<Eintrag>> getMeineVormerkungen(String userId) {
    return _firestore
        .collectionGroup('vormerkungen')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
          final eintragIds = snapshot.docs.map((doc) => doc.reference.parent.parent!.id).toSet().toList();
          if (eintragIds.isEmpty) return [];

          final eintraegeSnapshot = await _firestore
              .collection('eintraege')
              .where(FieldPath.documentId, whereIn: eintragIds)
              .get();

          return eintraegeSnapshot.docs.map((doc) => Eintrag.fromSnapshot(doc)).toList();
    });
  }

  // Prüfen, ob ein Nutzer einen Artikel vorgemerkt hat
  Stream<bool> hatVorgemerkt(String eintragId, String userId) {
    return _firestore
        .collection('eintraege')
        .doc(eintragId)
        .collection('vormerkungen')
        .doc(userId)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  // Anzahl der Vormerkungen für einen Eintrag erhalten
  Stream<int> getVormerkungenCount(String eintragId) {
    return _firestore
        .collection('eintraege')
        .doc(eintragId)
        .collection('vormerkungen')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }
}
