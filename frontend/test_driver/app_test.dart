import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

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

    test('Try right credentials', () async {
      // Find the button by its label.
      final username_field = find.byValueKey('username');
      final password_field = find.byValueKey('password');
      final button = find.text('Login');

      await driver?.tap(username_field);
      await driver?.enterText("user1");

      await driver?.tap(password_field);
      await driver?.enterText("pass1");

      await driver?.tap(button);



    });

    test('Try false credentials', () async {
      // Find the button by its label.
      final username_field = find.byValueKey('username');
      final password_field = find.byValueKey('password');
      final button = find.byValueKey('Login');

      await driver?.tap(username_field);
      await driver?.enterText("user");

      await driver?.tap(password_field);
      await driver?.enterText("pass");

      await driver?.tap(button);

      final failedWidget = find.byValueKey('failedLogin');

      final oneWidget = await driver?.findWidgets(failedWidget).evaluate();
      expect(oneWidget, hasLength(1));

    });
  });
}
