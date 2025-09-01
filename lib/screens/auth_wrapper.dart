import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'home_screen.dart'; // Import the real home screen

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    // Der HomeScreen ist nun der Hauptbildschirm für alle Nutzer.
    // Der Login-Status (isAdmin) steuert nur die Admin-Funktionen *innerhalb* des HomeScreens.
    // Gemäss Anforderung soll der Katalog für alle sichtbar sein.
    // Der Admin-Login schaltet nur die Bearbeitungsfunktionen frei.

    // Wir zeigen IMMER den HomeScreen. Die Admin-Funktionen darin
    // werden durch den `authService.isAdmin` Status gesteuert.
    // Ein expliziter Login-Screen wird nur benötigt, wenn der Admin
    // auf eine geschützte Aktion zugreifen will.
    //
    // Überarbeitung der Logik: Die App startet immer im Katalog.
    // Ein "Login"-Button im UI führt zum Login-Screen.
    // Das vereinfacht den Einstieg für normale Nutzer.

    // Fürs Erste behalten wir die alte Logik bei, um den Plan zu erfüllen,
    // aber eine bessere UX wäre, den Katalog immer zu zeigen.
    // Ich werde die Anforderung "Admin-Funktionen nur sichtbar nach Login"
    // so interpretieren, dass die App mit dem Katalog startet und ein Login-Button
    // im UI vorhanden ist.

    // Um den Plan aber schrittweise umzusetzen, bleibe ich bei:
    // Nicht-Admin -> Login-Screen (vorerst)
    // Admin -> HomeScreen
    // Dieser Teil wird später verfeinert, um allen Nutzern den Katalog zu zeigen.

    if (authService.isAdmin) {
      return const HomeScreen();
    } else {
      // Temporäre Logik: Um Admin-Funktionen zu testen, muss man sich einloggen.
      // Später wird der HomeScreen der Standard sein und ein Login-Button im UI.
      // Für jetzt, um den Admin-Login-Flow zu bauen, ist das so korrekt.
      // ABER die Anforderung ist, dass der Katalog für ALLE Nutzer sichtbar ist.
      // Also muss der HomeScreen immer sichtbar sein.
      // Ich korrigere das jetzt.
      return const HomeScreen();
    }
  }
}
