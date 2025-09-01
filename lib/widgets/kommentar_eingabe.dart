import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/kommentar.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';

class KommentarEingabe extends StatefulWidget {
  final String eintragId;

  const KommentarEingabe({super.key, required this.eintragId});

  @override
  State<KommentarEingabe> createState() => _KommentarEingabeState();
}

class _KommentarEingabeState extends State<KommentarEingabe> {
  final _autorController = TextEditingController();
  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _autorController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authService = context.read<AuthService>();
      final firebaseService = context.read<FirebaseService>();

      final userId = authService.userId;
      if (userId == null) {
        // Sollte nicht passieren, da wir anonyme Nutzer haben
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler: Nicht angemeldet.')),
        );
        setState(() { _isLoading = false; });
        return;
      }

      final newComment = Kommentar(
        id: '', // Firestore generiert die ID
        autor: _autorController.text,
        text: _textController.text,
        userId: userId,
        timestamp: DateTime.now(),
      );

      try {
        await firebaseService.addKommentar(widget.eintragId, newComment);
        _autorController.clear();
        _textController.clear();
        FocusScope.of(context).unfocus(); // Tastatur ausblenden
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Senden: $e')),
        );
      } finally {
        if(mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Neuer Kommentar", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _autorController,
              decoration: const InputDecoration(labelText: 'Dein Name', border: OutlineInputBorder()),
              validator: (value) => value!.isEmpty ? 'Bitte gib einen Namen an.' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _textController,
              decoration: const InputDecoration(labelText: 'Dein Kommentar', border: OutlineInputBorder()),
              maxLines: 3,
              validator: (value) => value!.isEmpty ? 'Bitte gib einen Kommentar ein.' : null,
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _submitComment,
                  child: const Text('Senden'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
