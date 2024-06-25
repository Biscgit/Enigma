import 'dart:io';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  FlutterDriver? driver;

  // Connect to the Flutter app before running the tests.
  setUpAll(() async => {
        await Directory('screenshots').create(),
      });

  setUp(() async {
    driver = await FlutterDriver.connect();
    driver?.checkHealth();
  });

  // Close the connection to the Flutter app after tests are done.
  tearDown(() async {
    if (driver != null) {
      driver?.close();
    }
  });

  test('Check flutter driver health', () async {
    Health? health = await driver?.checkHealth();
    assert(health?.status == HealthStatus.ok);
  });

  // Login e2e test
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

    // check if message appears
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

  test('Login empty credentials', () async {
    // Find the button by its label.
    final usernameField = find.byValueKey('username');
    final passwordField = find.byValueKey('password');
    final button = find.byValueKey('Login');

    await driver?.tap(usernameField);
    await driver?.enterText("");

    await driver?.tap(passwordField);
    await driver?.enterText("");

    await driver?.tap(button);

    // check if message appears
    await driver?.waitFor(
      find.byValueKey('failedLogin'),
      timeout: const Duration(seconds: 5),
    );
  });

  test('Login wrong and correct after', () async {
    // Find the button by its label.
    final usernameField = find.byValueKey('username');
    final passwordField = find.byValueKey('password');
    final button = find.byValueKey('Login');

    await driver?.tap(usernameField);
    await driver?.enterText("user1");

    await driver?.tap(passwordField);
    await driver?.enterText("WRONG_password!");

    await driver?.tap(button);

    // check if message appears
    await driver?.waitFor(
      find.byValueKey('failedLogin'),
      timeout: const Duration(seconds: 5),
    );
    await driver?.tap(find.text("OK"));

    await driver?.tap(usernameField);
    await driver?.enterText("user2");

    await driver?.tap(passwordField);
    await driver?.enterText("pass2");

    await driver?.tap(button);

    // check if message appears
    await driver?.waitForAbsent(
      find.byValueKey('failedLogin'),
      timeout: const Duration(seconds: 5),
    );
  });

  test('Logout correct credentials', () async {
    // Execute login
    final usernameField = find.byValueKey('username');
    final passwordField = find.byValueKey('password');
    final button = find.text('Login');

    await driver?.tap(usernameField);
    await driver?.enterText("user1");

    await driver?.tap(passwordField);
    await driver?.enterText("pass1");

    await driver?.tap(button);

    // Execute logout
    final logoutButton = find.byValueKey("logoutButton");
    await driver?.tap(logoutButton);

    // check if message appears
    await driver?.waitFor(
      find.byValueKey('logoutDialog'),
      timeout: const Duration(seconds: 5),
    );
    // takeScreenshot(driver!, "logged_out.png");

    // tap away
    await driver?.tap(find.text("OK"));

    // check if gone
    await driver?.waitForAbsent(
      find.byValueKey('logoutDialog'),
      timeout: const Duration(seconds: 5),
    );
  });
}
