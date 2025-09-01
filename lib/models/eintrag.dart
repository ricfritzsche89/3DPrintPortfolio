import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Eintrag extends Equatable {
  final String id;
  final String titel;
  final String beschreibung;
  final String kategorie;
  final double? preis;
  final String bildUrl;
  final DateTime erstelltAm;

  const Eintrag({
    required this.id,
    required this.titel,
    required this.beschreibung,
    required this.kategorie,
    this.preis,
    required this.bildUrl,
    required this.erstelltAm,
  });

  @override
  List<Object?> get props => [id, titel, beschreibung, kategorie, preis, bildUrl, erstelltAm];

  // Erstellt ein Eintrag-Objekt aus einem Firestore-Dokument
  factory Eintrag.fromSnapshot(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;
    return Eintrag(
      id: snap.id,
      titel: data['titel'] ?? '',
      beschreibung: data['beschreibung'] ?? '',
      kategorie: data['kategorie'] ?? '',
      preis: (data['preis'] as num?)?.toDouble(),
      bildUrl: data['bildUrl'] ?? '',
      erstelltAm: (data['erstelltAm'] as Timestamp).toDate(),
    );
  }

  // Konvertiert ein Eintrag-Objekt in eine Map für Firestore
  Map<String, dynamic> toJson() {
    return {
      'titel': titel,
      'beschreibung': beschreibung,
      'kategorie': kategorie,
      'preis': preis,
      'bildUrl': bildUrl,
      'erstelltAm': Timestamp.fromDate(erstelltAm),
    };
  }
}
