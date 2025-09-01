import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/eintrag.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../widgets/eintrag_card.dart';

class MerklisteScreen extends StatelessWidget {
  const MerklisteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Merkliste'),
      ),
      body: userId == null
          ? const Center(child: Text('Fehler: Kein Benutzer angemeldet.'))
          : StreamBuilder<List<Eintrag>>(
              stream: firebaseService.getMeineVormerkungen(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print(snapshot.error); // Log for debugging
                  return const Center(child: Text('Fehler beim Laden der Merkliste.'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Du hast noch keine Artikel vorgemerkt.'));
                }

                final eintraege = snapshot.data!;

                // GridView mit LayoutBuilder für ein responsives Layout
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final crossAxisCount = (width / 200).floor().clamp(2, 4);

                    return GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: eintraege.length,
                      itemBuilder: (context, index) {
                        return EintragCard(eintrag: eintraege[index]);
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
