import 'package:flutter/material.dart';

class SideBar extends StatelessWidget {
  final Function(String) onItemSelected;

  SideBar({required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('Wähle deine Enigma'),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            title: Text('Enigma I'),
            onTap: () {
              onItemSelected('Enigma I');
	      Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Norway Enigma'),
            onTap: () {
              onItemSelected('Norway Enigma');
	      Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Enigma 3'),
            onTap: () {
              onItemSelected('Enigma 3');
	      Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
