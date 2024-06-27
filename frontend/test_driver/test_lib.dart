import 'dart:io';
import 'package:flutter_driver/flutter_driver.dart';

takeScreenshot(FlutterDriver driver, String path) async {
  await driver.waitUntilNoTransientCallbacks();
  final List<int> pixels = await driver.screenshot();
  final File file = File("screenshots/$path");
  await file.writeAsBytes(pixels);
}

Future<void> login(FlutterDriver? driver,
    {String username = "user1", String password = "pass1"}) async {
  final usernameField = find.byValueKey('username');
  final passwordField = find.byValueKey('password');
  final button = find.text('Login');

  await driver?.tap(usernameField);
  await driver?.enterText(username);

  await driver?.tap(passwordField);
  await driver?.enterText(password);

  await driver?.tap(button);
  await Future.delayed(const Duration(seconds: 1));
}

Future<void> logout(FlutterDriver? driver) async {
  final logoutButton = find.byValueKey("logoutButton");
  await driver?.tap(logoutButton);

  await driver?.waitFor(
    find.byValueKey('logoutDialog'),
    timeout: const Duration(seconds: 5),
  );

  await driver?.tap(find.text("OK"));

  await driver?.waitForAbsent(
    find.byValueKey('logoutDialog'),
    timeout: const Duration(seconds: 5),
  );
}

Future<void> resetSelectedMachine(FlutterDriver? driver) async {
  final resetButton = find.byValueKey("Reset_button");
  await driver?.tap(resetButton);
  await driver?.waitFor(
    find.byValueKey("Confirm_revert"),
    timeout: const Duration(seconds: 3),
  );

  await driver?.tap(find.byValueKey("Confirm_revert"));
  await driver?.waitFor(
    find.byValueKey("keyHistoryList"),
    timeout: const Duration(seconds: 10),
  );
  await Future.delayed(const Duration(seconds: 1));
}

Future<void> writeChar(String char, FlutterDriver? driver) async {
  assert(char.length == 1);
  await driver?.tap(find.byValueKey("Tastatur-Button-${char.toUpperCase()}"));
}
