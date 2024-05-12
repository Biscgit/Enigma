import 'package:flutter/material.dart';
//import 'utils.dart';
import 'package:enigma/lampenfeld.dart';
import 'package:enigma/sidebar.dart';


class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Page'),
      ),
      drawer: SideBar(),
      body: Lampfield(),
    );
  }
}
