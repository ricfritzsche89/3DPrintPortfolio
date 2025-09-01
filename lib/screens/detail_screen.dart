import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/eintrag.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../widgets/kommentar_eingabe.dart';
import '../widgets/kommentar_liste.dart';
import '../widgets/vormerk_button.dart';
import 'edit_eintrag_screen.dart';

class DetailScreen extends StatelessWidget {
  final Eintrag eintrag;

  const DetailScreen({super.key, required this.eintrag});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(eintrag.titel),
        actions: [
          if (authService.isAdmin)
            _buildAdminActions(context),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              eintrag.bildUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Icon(Icons.broken_image, size: 100, color: Colors.grey));
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eintrag.titel,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          eintrag.kategorie,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                        ),
                      ),
                      if (eintrag.preis != null)
                        Text(
                          '${eintrag.preis!.toStringAsFixed(2)} €',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (authService.isAdmin) _buildAdminVormerkungenCount(context),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text('Beschreibung', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(eintrag.beschreibung, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5)),
                  const SizedBox(height: 24),
                  Center(child: VormerkButton(eintragId: eintrag.id)),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text('Kommentare', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  KommentarEingabe(eintragId: eintrag.id),
                  const SizedBox(height: 16),
                  KommentarListe(eintragId: eintrag.id),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminActions(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Bearbeiten',
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => EditEintragScreen(eintrag: eintrag),
            ));
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          tooltip: 'Löschen',
          onPressed: () => _confirmDelete(context),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Wirklich löschen?'),
        content: Text('Möchtest du den Eintrag "${eintrag.titel}" wirklich endgültig löschen? Diese Aktion kann nicht rückgängig gemacht werden.'),
        actions: [
          TextButton(
            child: const Text('Abbrechen'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Löschen', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              final firebaseService = context.read<FirebaseService>();
              try {
                await firebaseService.deleteEintrag(eintrag.id, eintrag.bildUrl);
                Navigator.of(ctx).pop(); // Dialog schließen
                Navigator.of(context).pop(); // DetailScreen verlassen
              } catch (e) {
                 Navigator.of(ctx).pop();
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text('Fehler beim Löschen: $e')),
                 );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdminVormerkungenCount(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context, listen: false);
    return StreamBuilder<int>(
      stream: firebaseService.getVormerkungenCount(eintrag.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final count = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Anzahl Vormerkungen: $count',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
