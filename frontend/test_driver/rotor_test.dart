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

  test("Rotors exists", timeout: const Timeout(Duration(seconds: 60)),
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

  test("Plus-Minus-Notch", timeout: const Timeout(Duration(seconds: 60)),
          () async {
        await login(driver);
        await resetSelectedMachine(driver);

        final plusButton = find.byValueKey("ChangeLetter.1.plus");
        final minusButton = find.byValueKey("ChangeLetter.1.minus");
        final notchKey = find.byValueKey("Notch.1");

        // Current value
        Future<String?> getNotchValue() async {
          return await driver?.getText(notchKey);
        }

        // initial value is Y
        await getNotchValue();
        await driver?.waitFor(find.text('Y'));

        // Plus button (rom Y to Z)
        await driver?.tap(plusButton);
        await getNotchValue();
        await driver?.waitFor(find.text('Z'));

        // Reset notch
        await driver?.tap(minusButton); // Y

        // Minus Button (From Y to X)
        await driver?.tap(minusButton);
        await getNotchValue();
        await driver?.waitFor(find.text('X'));
      });

  //test("Rotors rotate", timeout: const Timeout(Duration(seconds: 60)),
  //() async {
  //});


}