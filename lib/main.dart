import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import './firebase_options.dart';

import 'app.dart';

void main() {
  (() async {
    // Ensure that the flutter bindings have been initialized
    WidgetsFlutterBinding.ensureInitialized();
    // Initializing Firebase Application
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Intializing Flutter App
    runApp(const MyApp());
  })();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: "KaushanScript",
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 246, 246),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 244, 217, 185)),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color.fromARGB(255, 255, 246, 246),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              width: 2,
              color: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 244, 217, 185))
                  .primary,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 244, 217, 185))
                  .primary,
            ),
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: ColorScheme.fromSwatch(primarySwatch: Colors.red).primary,
            ),
          ),
        ),
      ),
      home: const App(),
    );
  }
}
