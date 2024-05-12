import 'package:flutter/material.dart';
import 'utils.dart';

// choose between 3 different enigma machines
//...

//----------------------------------------------------
class HomePage extends StatelessWidget {

  void _logout(BuildContext context) async {
    await Cookie.delete('token');
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            tooltip: 'Logout',
            onPressed: () {
              _logout(context);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: Text('Logout Confirmation'),
                    content: Text('Successfully logged out'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Choose the enigma machine:'),
      ),
    );
  }
}
