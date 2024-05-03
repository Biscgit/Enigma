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

    test('Tap Enigma buttons and verify error message', () async {
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

      // Add a delay to ensure the error message has time to appear
      await Future.delayed(Duration(seconds: 2));

      // Check if the error message is displayed
      bool isErrorMessageDisplayed = await isErrorMessageVisible(driver!);
      expect(isErrorMessageDisplayed, isTrue);
    });
  });
}

Future<bool> isErrorMessageVisible(FlutterDriver driver) async {
  // Define a timeout duration for waiting for the error message
  const Duration timeout = Duration(seconds: 5);

  // Try to find the error message within the specified timeout
  try {
    await driver.waitFor(find.text('Error message'), timeout: timeout);
    return true; // If found, return true
  } catch (e) {
    return false; // If not found, return false
  }
}
