import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Vormerkung extends Equatable {
  final String id;
  final String userId;
  final DateTime timestamp;

  const Vormerkung({
    required this.id,
    required this.userId,
    required this.timestamp,
  });

  @override
  List<Object> get props => [id, userId, timestamp];

  factory Vormerkung.fromSnapshot(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;
    return Vormerkung(
      id: snap.id,
      userId: data['userId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
