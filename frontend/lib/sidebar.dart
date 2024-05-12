import 'package:flutter/material.dart';

class SideBar extends StatefulWidget {
//  const SideBar({Key? key}) : super(key: key);

  @override
  State<SideBar> createState() => SideBarState();
}

class SideBarState extends State<SideBar> {
  String currentMachine = 'Enigma I';

  void loadEnigmaI() {
    setState(() {
      currentMachine = 'Enigma I';
    });
  }

  void loadNorwayEnigma() {
    setState(() {
      currentMachine = 'Norway Enigma';
    });
  }

  void loadEnigmaM3() {
    setState(() {
      currentMachine = 'Enigma M3';
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Choose Enigma mode',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SizedBox(
              width: screenWidth * 0.5,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  loadEnigmaI();
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.green; // Change button color if pressed
                      }
                      return currentMachine == 'Enigma I'
                          ? Colors.green // Change button color if selected
                          : const Color.fromARGB(255, 33, 150, 243);
                    },
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
                child: const Text(
                  'Enigma I',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: SizedBox(
              width: screenWidth * 0.5,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  loadNorwayEnigma();
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.green; // Change button color if pressed
                      }
                      return currentMachine == 'Norway Enigma'
                          ? Colors.green // Change button color if selected
                          : const Color.fromARGB(255, 33, 150, 243);
                    },
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
                child: const Text(
                  'Norway Enigma',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: SizedBox(
              width: screenWidth * 0.5,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  loadEnigmaM3();
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.green; // Change button color if pressed
                      }
                      return currentMachine == 'Enigma M3'
                          ? Colors.green // Change button color if selected
                          : const Color.fromARGB(255, 33, 150, 243);
                    },
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
                child: const Text(
                  'Enigma M3',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

