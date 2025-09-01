import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';

class VormerkButton extends StatelessWidget {
  final String eintragId;

  const VormerkButton({super.key, required this.eintragId});

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.userId;

    if (userId == null) {
      // Zeige einen deaktivierten Button, wenn kein User (auch kein anonymer) da ist.
      // Sollte in unserer Implementierung nicht passieren.
      return const ElevatedButton.icon(
        onPressed: null,
        icon: Icon(Icons.favorite_border),
        label: Text('Vormerken'),
      );
    }

    return StreamBuilder<bool>(
      stream: firebaseService.hatVorgemerkt(eintragId, userId),
      builder: (context, snapshot) {
        // Standardwert ist false, bis der Stream Daten liefert.
        final hatVorgemerkt = snapshot.data ?? false;
        final isLaden = snapshot.connectionState == ConnectionState.waiting;

        return ElevatedButton.icon(
          onPressed: isLaden ? null : () {
            firebaseService.toggleVormerkung(eintragId, userId, hatVorgemerkt);
          },
          icon: isLaden
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(hatVorgemerkt ? Icons.favorite : Icons.favorite_border),
          label: Text(hatVorgemerkt ? 'Vorgemerkt' : 'Vormerken'),
          style: ElevatedButton.styleFrom(
            backgroundColor: hatVorgemerkt ? Colors.pink[100] : null,
            foregroundColor: hatVorgemerkt ? Colors.pink[800] : null,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
        );
      },
    );
  }
}
