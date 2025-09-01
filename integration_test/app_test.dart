import 'package:ddd_druck_katalog/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../test/manual_mocks.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Admin Workflow: Login, Create, View, Delete', (WidgetTester tester) async {
    // Mocks für den Test erstellen
    final mockAuthService = MockAuthService();
    final mockFirebaseService = MockFirebaseService();

    // App mit den Mocks starten
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(MyApp(
        authService: mockAuthService,
        firebaseService: mockFirebaseService,
      ));
      await tester.pumpAndSettle();

      // --- 1. Login ---
      // Finde den Login-Button in der AppBar und tippe darauf
      await tester.tap(find.byIcon(Icons.login));
      await tester.pumpAndSettle(); // Warte auf Navigation

      // Überprüfe, ob der LoginScreen sichtbar ist
      expect(find.text('Admin-Login'), findsOneWidget);

      // Gib die Anmeldedaten ein (sind im Test bereits voreingefüllt)
      await tester.enterText(find.widgetWithText(TextFormField, 'Benutzername'), 'Ric89');
      await tester.enterText(find.widgetWithText(TextFormField, 'Passwort'), 'Nadineundric22');

      // Tippe auf den Anmelde-Button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Anmelden'));
      await tester.pumpAndSettle(); // Warte auf Navigation

      // --- 2. Überprüfe HomeScreen als Admin ---
      // Der FloatingActionButton sollte jetzt sichtbar sein
      expect(find.byIcon(Icons.add), findsOneWidget);
      // Der ursprüngliche Test-Eintrag sollte sichtbar sein
      expect(find.text('Bestehender Eintrag'), findsOneWidget);

      // --- 3. Eintrag erstellen ---
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Fülle das Formular aus
      const newTitle = 'Neuer Testdruck';
      await tester.enterText(find.widgetWithText(TextFormField, 'Titel'), newTitle);
      await tester.enterText(find.widgetWithText(TextFormField, 'Beschreibung'), 'Eine tolle Beschreibung.');
      await tester.enterText(find.widgetWithText(TextFormField, 'Kategorie'), 'Automation');
      await tester.enterText(find.widgetWithText(TextFormField, 'Preis (optional)'), '49.99');

      // Speichern (Bildauswahl wird übersprungen, da im Mock nicht nötig)
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      // --- 4. Überprüfen, ob der neue Eintrag da ist ---
      expect(find.text(newTitle), findsOneWidget);

      // --- 5. Eintrag löschen ---
      // Tippe auf den neuen Eintrag, um zur Detailseite zu gelangen
      await tester.tap(find.text(newTitle));
      await tester.pumpAndSettle();

      // Überprüfe, ob wir auf der Detailseite sind
      expect(find.text('Beschreibung'), findsOneWidget);

      // Tippe auf den Löschen-Button in der AppBar
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Bestätige im Dialog
      await tester.tap(find.widgetWithText(TextButton, 'Löschen'));
      await tester.pumpAndSettle();

      // --- 6. Überprüfen, ob der Eintrag weg ist ---
      // Wir sollten jetzt wieder auf dem HomeScreen sein
      expect(find.byIcon(Icons.add), findsOneWidget);
      // Der gelöschte Eintrag sollte nicht mehr da sein
      expect(find.text(newTitle), findsNothing);
      // Der ursprüngliche Eintrag sollte noch da sein
      expect(find.text('Bestehender Eintrag'), findsOneWidget);
    });
  });
}
