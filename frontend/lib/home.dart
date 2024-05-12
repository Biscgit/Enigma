import 'package:flutter/material.dart';
//import 'utils.dart';
import 'package:enigma/lampenfeld.dart';
import 'package:enigma/sidebar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedItem = 'Enigma I'; 

  void updateSelectedItem(String item) {
    setState(() {
      selectedItem = item;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$selectedItem'),
      ),
      drawer: SideBar(onItemSelected: updateSelectedItem),
      body: Lampfield(),
    );
  }
}
