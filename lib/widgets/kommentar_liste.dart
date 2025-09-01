import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/kommentar.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import 'package:intl/intl.dart'; // Benötigt das intl-Paket, füge ich zur pubspec.yaml hinzu

class KommentarListe extends StatelessWidget {
  final String eintragId;

  const KommentarListe({super.key, required this.eintragId});

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);
    final authService = Provider.of<AuthService>(context);
    final currentUserId = authService.userId;

    return StreamBuilder<List<Kommentar>>(
      stream: firebaseService.getKommentare(eintragId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print(snapshot.error); // Log for debugging
          return const Center(child: Text('Fehler beim Laden der Kommentare.'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Sei der Erste, der einen Kommentar schreibt!'));
        }

        final kommentare = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true, // Wichtig, da in einer SingleChildScrollView
          physics: const NeverScrollableScrollPhysics(), // Scrollen wird vom Parent übernommen
          itemCount: kommentare.length,
          itemBuilder: (context, index) {
            final kommentar = kommentare[index];
            final isOwnComment = kommentar.userId == currentUserId;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                title: Text(kommentar.autor),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(kommentar.text),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd.MM.yyyy, HH:mm').format(kommentar.timestamp),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                trailing: isOwnComment
                    ? IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          // Bestätigungsdialog anzeigen
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Kommentar löschen?'),
                              content: const Text('Möchtest du diesen Kommentar wirklich endgültig löschen?'),
                              actions: [
                                TextButton(
                                  child: const Text('Abbrechen'),
                                  onPressed: () => Navigator.of(ctx).pop(),
                                ),
                                TextButton(
                                  child: const Text('Löschen'),
                                  onPressed: () {
                                    firebaseService.deleteKommentar(eintragId, kommentar.id);
                                    Navigator.of(ctx).pop();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}
