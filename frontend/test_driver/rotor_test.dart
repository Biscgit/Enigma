import 'dart:async';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'test_lib.dart';

void main() {
  FlutterDriver? driver;

  setUp(() async {
    driver = await FlutterDriver.connect();
    driver?.checkHealth();
  });

  tearDown(() async {
    if (driver != null) {
      driver?.close();
    }
  });

  test("Rotor exists", timeout: const Timeout(Duration(seconds: 60)),
          () async {
        await login(driver);
        await resetSelectedMachine(driver);

        final rotor1 = find.text('Rotor 1');
        final rotor2 = find.text('Rotor 2');
        final rotor3 = find.text('Rotor 3');
        await driver?.waitFor(rotor1);
        await driver?.waitFor(rotor2);
        await driver?.waitFor(rotor3);
      });
}