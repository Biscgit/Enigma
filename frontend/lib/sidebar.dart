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
 //   final screenWidth = MediaQuery.of(context).size.width;

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
	      Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Norway Enigma'),
            onTap: () {
	      Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Enigma 3'),
            onTap: () {
	      Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}


/*
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ,
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
*/
