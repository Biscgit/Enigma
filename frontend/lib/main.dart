import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PageVariants extends StatelessWidget {
  const PageVariants({Key? key});

  @override
  Widget build(BuildContext context) {
    final screenWidth =
        MediaQuery.of(context).size.width; // Get the screen width

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          // Center the first button
          child: SizedBox(
            width: screenWidth * 0.5,
            // Set button width to half of the screen width
            height: 40,
            // Adjust the height of the buttons
            child: ElevatedButton(
              onPressed: () {
                _launchURL('https://enigmai.com');
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    const Color.fromARGB(255, 33, 150, 243)),
                // Change button color
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20.0), // Set button border radius
                  ),
                ),
              ),
              child: const Text(
                'Enigma I',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.white), // Adjust the font size and color
              ),
            ),
          ),
        ),
        const SizedBox(height: 8), // Add some space between buttons
        Center(
          // Center the second button
          child: SizedBox(
            width: screenWidth * 0.5,
            // Set button width to half of the screen width
            height: 40,
            // Adjust the height of the buttons
            child: ElevatedButton(
              onPressed: () {
                _launchURL('https://google.com');
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    const Color.fromARGB(255, 33, 150, 243)),
                // Change button color
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20.0), // Set button border radius
                  ),
                ),
              ),
              child: const Text(
                'Norway Enigma',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.white), // Adjust the font size and color
              ),
            ),
          ),
        ),
        const SizedBox(height: 8), // Add some space between buttons
        Center(
          // Center the third button
          child: SizedBox(
            width: screenWidth * 0.5,
            // Set button width to half of the screen width
            height: 40,
            // Adjust the height of the buttons
            child: ElevatedButton(
              onPressed: () {
                _launchURL('https://enigmam3.com');
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    const Color.fromARGB(255, 33, 150, 243)),
                // Change button color
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20.0), // Set button border radius
                  ),
                ),
              ),
              child: const Text(
                'Enigma M3',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.white), // Adjust the font size and color
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue, // Set app bar color to blue
          title: const Text(
            'Choose Enigma mode',
            style: TextStyle(fontSize: 24, color: Colors.white), // Adjust the font size and color
          ),
          centerTitle: true, // Center the title horizontally
        ),
        body: const PageVariants(),
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}
