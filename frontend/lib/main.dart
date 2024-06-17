import 'package:flutter/material.dart';
import 'package:enigma/home.dart';
import 'package:enigma/login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  await dotenv.load(fileName: "flutter.env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        primaryColor: Colors.grey[900],
        colorScheme: ColorScheme.dark(
          primary: Colors.grey[900]!,
          secondary: Colors.blueAccent,
          surface: Colors.black,
          onSurface: Colors.white70,
        ),
     //   accentColor: Colors.blueAccent,
        // Add more dark theme settings here
      ),
      themeMode: ThemeMode.system, // Change to ThemeMode.dark or ThemeMode.light if needed
      debugShowCheckedModeBanner: false,
      /*theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),*/
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (context) => LoginPage());
          case '/home':
            return MaterialPageRoute(builder: (context) => const HomePage());
          default:
            return MaterialPageRoute(builder: (context) => LoginPage());
        }
      },
    );
  }
}
