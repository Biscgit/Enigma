import 'package:flutter/material.dart';
import 'utils.dart';
import 'dart:convert';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginPage extends StatelessWidget {
  // replace 172.20.0.101 with localhost on Windows
  // static String apiUrl = 'http://${dotenv.env['IP_FASTAPI']}:8001/login';

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginPage({super.key});

  // bool hasShowed = false;
  Future<bool> _checkServerOn() async {
    // check server accessible
    try {
      final response = await APICaller.get("ping");
      return (response.statusCode == 200 && jsonDecode(response.body) == "OK");
    } catch (e) {
      return false;
    }
  }

  Future<bool> _isAuthenticated() async {
    final response = await APICaller.get("is_authenticated");
    return (response.statusCode == 200 && jsonDecode(response.body) == true);
  }

  void _showSnackbar(BuildContext context, String message, Color color) {
    //if (!hasShowed) {
    // hasShowed = true;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        showCloseIcon: true,
        duration: const Duration(days: 1),
      ),
    );
    // }
  }

  Future<void> _login(BuildContext context) async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    final response = await APICaller.post("login", body: {
      "username": username,
      "password": password,
    });

    if (response.statusCode == 200) {
      final token = jsonDecode(response.body)["token"];
      await Cookie.save('token', token);

      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            key: const ValueKey('failedLogin'),
            title: const Text('Login failed'),
            content: const Text('Invalid username or password'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double loginWidth = screenHeight * 0.6;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final isOnline = await _checkServerOn();
      if (!context.mounted) return;

      if (isOnline) {
        _showSnackbar(
          context,
          'Backend online!',
          Colors.green,
        );
      } else {
        _showSnackbar(
          context,
          'Backend cannot be reached, check your connection, docker or network!',
          Colors.red,
        );
      }
    });

    final buttonStyle = ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Theme.of(context).primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enigma Login'),
        leading: Container(),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            constraints: BoxConstraints(maxWidth: screenWidth),
            width: loginWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  key: const ValueKey('username'),
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  key: const ValueKey('password'),
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  onSubmitted: (value) => _login(context),
                ),
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton(
                      key: const ValueKey('Login'),
                      onPressed: () async => await _login(context),
                      style: buttonStyle,
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(width: 10),
                    ElevatedButton(
                      style: buttonStyle,
                      onPressed: () async {
                        if (await _isAuthenticated()) {
                          if (!context.mounted) return;
                          Navigator.pushReplacementNamed(context, '/home');
                        } else {
                          if (!context.mounted) return;
                          _showSnackbar(
                            context,
                            "No authenticated sessions found! Please login again",
                            Colors.deepOrange,
                          );
                        }
                      },
                      child: const Text('Continue session'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
