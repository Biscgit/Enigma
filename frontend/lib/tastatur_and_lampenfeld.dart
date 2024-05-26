import 'package:flutter/material.dart';
import 'lampenfeld.dart'; // Make sure to import your Lampfield widget here
import 'tastatur.dart'; // Import the Tastatur widget

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Lampfield(), // Add the Lampfield widget here
          ),
          Expanded(
            flex: 1,
            child: Tastatur(), // Add the Tastatur widget here
          ),
        ],
      ),
    );
  }
}
