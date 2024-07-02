import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'utils.dart';
import 'dart:convert';

class LoginPage extends StatefulWidget {
  static bool notificationSent = false;

  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
    try {
      final response = await APICaller.get("is_authenticated");
      return (response.statusCode == 200 && jsonDecode(response.body) == true);
    } catch (_) {
      return false;
    }
  }

  void _showSnackbar(BuildContext context, String message, Color color,
      {Color textColor = Colors.black,
      Duration duration = const Duration(days: 1)}) {
    //if (!hasShowed) {
    // hasShowed = true;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor),
        ),
        backgroundColor: color,
        showCloseIcon: true,
        closeIconColor: textColor,
        duration: duration,
      ),
    );
    // }
  }

  void _login(BuildContext context) {
    String username = _usernameController.text;
    String password = _passwordController.text;

    APICaller.post("login", body: {"username": username, "password": password})
        .then((response) {
      return Cookie.save("current_machine", "1")
          .then((_) => Cookie.save("name", "Enigma I"))
          .then((_) => Cookie.save("username", username))
          .then((_) => Cookie.save("numberRotors", "3"))
          .then((_) {
        if (response.statusCode == 200) {
          final token = json.decode(response.body)["token"];
          return Cookie.save('token', token)
              .then((_) => Navigator.of(context).pushNamed('/home'));
        } else {
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
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double loginWidth = screenHeight * 0.6;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (LoginPage.notificationSent == true) return;
      LoginPage.notificationSent = true;

      final isOnline = await _checkServerOn();
      if (!context.mounted) return;

      if (isOnline) {
        _showSnackbar(
          context,
          'Backend online!',
          Colors.green.withOpacity(0.7),
          textColor: Colors.green.shade200,
          duration: const Duration(seconds: 5),
        );
      } else {
        _showSnackbar(
          context,
          'Backend cannot be reached. Check your connection, docker or network!',
          Colors.red.withOpacity(0.7),
          textColor: Colors.red.shade200,
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

    final title = dotenv.get('IS_TEST_ENV', fallback: "") == "true"
        ? const Text("Enigma")
        : Column(
            children: [
              SizedBox(
                height: screenHeight * 0.15,
                child: Text(
                  'The Enigma-Machine',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: screenHeight * 0.1,
                    color: const Color(0xFF666870),
                    height: 1,
                    letterSpacing: -1,
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 1200.ms, color: const Color(0xFF80DDFF))
                    .animate()
                    .fadeIn(duration: 1200.ms, curve: Curves.easeOutQuad)
                    .slide(),
              ),
              const Text("by Code Lieferando",
                  style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 0.2),
                    fontSize: 19,
                  ))
            ],
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enigma Login'),
        leading: Container(),
      ),
      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.15),
          SizedBox(height: screenHeight * 0.2, child: title),
          SizedBox(height: screenHeight * 0.05),
          Center(
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
                          onPressed: () => _login(context),
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
                                Colors.deepOrange.withOpacity(0.7),
                                textColor: Colors.deepOrange.shade200,
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
          )
        ],
      ),
    );
  }
}
