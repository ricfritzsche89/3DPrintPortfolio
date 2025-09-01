import 'package:ddd_druck_katalog/models/eintrag.dart';
import 'package:ddd_druck_katalog/widgets/eintrag_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() {
  // Ein Beispieldaten-Objekt für den Test
  final testEintrag = Eintrag(
    id: '1',
    titel: 'Test Druck',
    beschreibung: 'Eine Beschreibung',
    kategorie: 'Gadget',
    preis: 19.99,
    bildUrl: 'https://example.com/image.jpg',
    erstelltAm: DateTime.now(),
  );

  testWidgets('EintragCard zeigt Titel, Kategorie und Preis korrekt an', (WidgetTester tester) async {
    // network_image_mock verwenden, um Image.network im Test-Kontext zu ermöglichen
    await mockNetworkImagesFor(() async {
      // Das Widget in einer Test-App rendern
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EintragCard(eintrag: testEintrag),
          ),
        ),
      );

      // Überprüfen, ob der Titel gefunden wird
      expect(find.text('Test Druck'), findsOneWidget);

      // Überprüfen, ob die Kategorie gefunden wird
      expect(find.text('Gadget'), findsOneWidget);

      // Überprüfen, ob der Preis korrekt formatiert gefunden wird
      expect(find.text('19.99 €'), findsOneWidget);
    });
  });

   testWidgets('EintragCard zeigt keinen Preis an, wenn keiner vorhanden ist', (WidgetTester tester) async {
    final eintragOhnePreis = Eintrag(
      id: '2',
      titel: 'Druck ohne Preis',
      beschreibung: 'Beschreibung',
      kategorie: 'Deko',
      preis: null, // Kein Preis
      bildUrl: 'https://example.com/image.jpg',
      erstelltAm: DateTime.now(),
    );

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EintragCard(eintrag: eintragOhnePreis),
          ),
        ),
      );

      // Überprüfen, ob der Titel gefunden wird
      expect(find.text('Druck ohne Preis'), findsOneWidget);

      // Überprüfen, ob der Preis NICHT gefunden wird. Das Fehlen des Euro-Zeichens ist ein guter Indikator.
      expect(find.textContaining('€'), findsNothing);
    });
  });
}
