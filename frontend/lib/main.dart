import 'package:flutter/material.dart';
import 'login.dart';
import 'home.dart';
//import 'rotor1.dart';
//import 'rotor2.dart';
//import 'rotor3.dart';
import 'dart:html';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  bool isUserLoggedIn() {
    String cookies = document.cookie ?? "";
    Map<String, String> cookieMap = {};
    cookies.split(";").forEach((String cookie) {
      List<String> kv = cookie.split("=");
      if (kv.length == 2) {
        cookieMap[kv[0].trim()] = kv[1].trim();
      }
    });
    return cookieMap.containsKey("token") && cookieMap["token"]!.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enigma Web App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      onGenerateRoute: (settings) {
        if (settings.name == '/home' && !isUserLoggedIn()) {
          return MaterialPageRoute(builder: (context) => LoginPage());
        }
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (context) => LoginPage());
          case '/home':
            return MaterialPageRoute(builder: (context) => HomePage());
          default:
            return MaterialPageRoute(builder: (context) => LoginPage());
        }
      },
    );
  }
}
