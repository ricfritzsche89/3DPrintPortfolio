import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/firebase_service.dart';
import 'screens/auth_wrapper.dart';

import 'widgets/error_boundary.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Error Handler für nicht abgefangene Fehler
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // Hier können wir Fehler an einen Logging-Service senden
    print('Uncaught error: ${details.exception}');
  };
  
  runApp(const ErrorBoundary(child: MyApp()));
}

class MyApp extends StatelessWidget {
  // Optionale Service-Instanzen für Testzwecke
  final AuthService? authService;
  final FirebaseService? firebaseService;

  const MyApp({super.key, this.authService, this.firebaseService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Wenn ein Mock-Service übergeben wird, benutze ihn. Sonst erstelle eine echte Instanz.
        ChangeNotifierProvider<AuthService>(
          create: (context) => authService ?? AuthService(),
        ),
        Provider<FirebaseService>(
          create: (context) => firebaseService ?? FirebaseService(),
        ),
      ],
      child: MaterialApp(
        title: '3D-Druck-Katalog',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}
