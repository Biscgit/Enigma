import 'package:enigma/home.dart';
import 'package:flutter/material.dart';

//Collect all frontend packages here for now; they will be fused together later on.
//Other flutter files can be run via flutter run <filepath>

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enigma Web App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
//          case '/login':
//            return MaterialPageRoute(builder: (context) => LoginPage());
          case '/home':
            return MaterialPageRoute(builder: (context) => HomePage());
          default:
            return MaterialPageRoute(builder: (context) => HomePage());
        }
      },
    );
  }
}
