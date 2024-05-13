import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Credentials Tests', () {
    FlutterDriver? driver;

    // Connect to the Flutter app before running the tests.
    setUp(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the Flutter app after tests are done.
    tearDown(() async {
      if (driver != null) {
        driver?.close();
      }
    });

    test('check flutter driver health', () async {
      Health? health = await driver?.checkHealth();
      assert(health?.status == HealthStatus.ok);
    });

    test('Login correct credentials', () async {
      // Find the button by its label.
      final usernameField = find.byValueKey('username');
      final passwordField = find.byValueKey('password');
      final button = find.text('Login');

      await driver?.tap(usernameField);
      await driver?.enterText("user1");

      await driver?.tap(passwordField);
      await driver?.enterText("pass1");

      await driver?.tap(button);
      await driver?.waitForAbsent(
        find.byValueKey('failedLogin'),
        timeout: const Duration(seconds: 5),
      );
    });

    test('Login incorrect credentials', () async {
      // Find the button by its label.
      final usernameField = find.byValueKey('username');
      final passwordField = find.byValueKey('password');
      final button = find.byValueKey('Login');

      await driver?.tap(usernameField);
      await driver?.enterText("user2");

      await driver?.tap(passwordField);
      await driver?.enterText("WRONG_password!");

      await driver?.tap(button);

      // check if message appears
      await driver?.waitFor(
        find.byValueKey('failedLogin'),
        timeout: const Duration(seconds: 5),
      );
    });
  });
}
