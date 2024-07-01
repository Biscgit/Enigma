import 'package:flutter/material.dart';
import 'package:enigma/home.dart';
import 'package:enigma/login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main({String isTest = "false"}) async {
  await dotenv.load(fileName: "flutter.env");
  dotenv.env["IS_TEST_ENV"] = isTest;
  runApp(const EnigmaApp());
}

class EnigmaApp extends StatelessWidget {
  const EnigmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enigma Web App',
      theme: ThemeData(
        brightness: Brightness.light,
        // Light theme settings
        primaryColor: Colors.blue,
        colorScheme: const ColorScheme.light(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
          surface: Colors.white,
          onSurface: Colors.black54,
        ),
        // accentColor: Colors.blueAccent,
        // Add more light theme settings here
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        // Dark theme settings
        primaryColor: const Color.fromRGBO(65, 105, 225, 1),
        colorScheme: const ColorScheme.dark(
          primary: Colors.blueAccent,
          secondary: Colors.redAccent,
          surface: Color.fromRGBO(16, 16, 24, 0.8),
          onSurface: Colors.white70,
          // only exception (for design), this cannot be done differently:
          // ignore: deprecated_member_use
          background: Color.fromRGBO(24, 24, 30, 1),
        ),
      ),
      themeMode: ThemeMode.system,
      // Change to ThemeMode.dark or ThemeMode.light if needed
      debugShowCheckedModeBanner: false,
      /*theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),*/
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            return MaterialPageRoute(builder: (context) => const HomePage());
          default:
            return MaterialPageRoute(builder: (context) => const LoginPage());
        }
      },
    );
  }
}
