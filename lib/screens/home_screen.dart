import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../models/eintrag.dart';
import '../widgets/eintrag_card.dart';
import 'login_screen.dart';
import 'merkliste_screen.dart';
import 'edit_eintrag_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final firebaseService = Provider.of<FirebaseService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('3D-Druck-Katalog'),
        actions: [
          // Button zur Merkliste
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Meine Merkliste',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const MerklisteScreen(),
              ));
            },
          ),
          // Zeige entweder einen Login- oder einen Logout-Button
          if (authService.isAdmin)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Abmelden',
              onPressed: () {
                authService.signOut();
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.login),
              tooltip: 'Admin-Login',
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ));
              },
            ),
        ],
      ),
      body: StreamBuilder<List<Eintrag>>(
        stream: firebaseService.getEintraege(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print(snapshot.error); // Log for debugging
            return const Center(child: Text('Fehler beim Laden der Einträge.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Noch keine Einträge vorhanden.'));
          }

          final eintraege = snapshot.data!;

          // LayoutBuilder verwenden, um die Spaltenanzahl dynamisch zu bestimmen
          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              // Bestimme die Anzahl der Spalten basierend auf der verfügbaren Breite
              final crossAxisCount = (width / 200).floor().clamp(2, 4); // Mind. 2, Max. 4 Spalten

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
      floatingActionButton: authService.isAdmin
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const EditEintragScreen(),
                ));
              },
              tooltip: 'Neuer Eintrag',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
