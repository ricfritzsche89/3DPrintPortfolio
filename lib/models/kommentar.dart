import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Kommentar extends Equatable {
  final String id;
  final String text;
  final String autor; // Anzeigename
  final String userId; // Firebase Auth UID
  final DateTime timestamp;

  const Kommentar({
    required this.id,
    required this.text,
    required this.autor,
    required this.userId,
    required this.timestamp,
  });

  @override
  List<Object> get props => [id, text, autor, userId, timestamp];

  factory Kommentar.fromSnapshot(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;
    return Kommentar(
      id: snap.id,
      text: data['text'] ?? '',
      autor: data['autor'] ?? 'Anonym',
      userId: data['userId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'autor': autor,
      'userId': userId,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
