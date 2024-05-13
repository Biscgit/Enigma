import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
//import 'package:enigma/utils.dart' as utils;

void main() {
  group('App E2E Test', () {
    FlutterDriver? driver;

    // Connect to the Flutter app before running the tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the Flutter app after tests are done.
    tearDownAll(() async {
      if (driver != null) {
        driver?.close();
      }
    });


    test('check flutter driver health', () async {
      Health? health = await driver?.checkHealth();
      print(health?.status);
    });

    test('Verify Button Tap', () async {
      // Find the button by its label.
      final username_field = find.byValueKey('username');
      final password_field = find.byValueKey('password');
      final button = find.byValueKey('Login');

      await driver?.tap(username_field);
      await driver?.enterText("user1");

      await driver?.tap(password_field);
      await driver?.enterText("pass1");

      await driver?.tap(button);

 //     print(await utils.Cookie.read('token'));
    });
  });
}
