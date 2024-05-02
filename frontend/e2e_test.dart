import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('App E2E Test', () {
    FlutterDriver? driver;

    // Connect to the Flutter driver before running any tests
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed
    tearDownAll(() async {
      if (driver != null) {
        await driver!.close();
      }
    });

    test('Tap Enigma buttons', () async {
      // Find the Enigma buttons by their text
      final enigma1Button = find.text('Enigma I');
      final norwayEnigmaButton = find.text('Norway Enigma');
      final enigmaM3Button = find.text('Enigma M3');

      // Tap the Enigma buttons one by one
      await driver!.tap(enigma1Button);
      await driver!.waitFor(find.text('Enigma I')); 

      await driver!.tap(norwayEnigmaButton);
      await driver!.waitFor(find.text('Norway Enigma'));

      await driver!.tap(enigmaM3Button);
      await driver!.waitFor(find.text('Enigma M3'));
    });
  });
}
