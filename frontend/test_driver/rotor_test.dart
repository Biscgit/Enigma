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

  test("Rotors rotate", timeout: const Timeout(Duration(seconds: 60)),
          () async {
    await login(driver);
    await resetSelectedMachine(driver);

    final plusButtonRotor1 = find.byValueKey("ChangeRotor.1.plus");
    final minusButtonRotor1 = find.byValueKey("ChangeRotor.1.minus");
    final rotorPosition1 = find.byValueKey("RotorPosition.1");

    final plusButtonRotor2 = find.byValueKey("ChangeRotor.2.plus");
    final minusButtonRotor2 = find.byValueKey("ChangeRotor.2.minus");
    final rotorPosition2 = find.byValueKey("RotorPosition.2");

    final plusButtonRotor3 = find.byValueKey("ChangeRotor.3.plus");
    final minusButtonRotor3 = find.byValueKey("ChangeRotor.3.minus");
    final rotorPosition3 = find.byValueKey("RotorPosition.2");

    Future<String?> getRotorPosition(int rotorNumber) async {
      final result = await driver?.requestData('getRotorPosition:$rotorNumber');
      return result;
    }

    // Initial values A
    await driver?.waitFor(find.byValueKey('RotorPosition.1'));
    await driver?.waitFor(find.byValueKey('RotorPosition.2'));
    await driver?.waitFor(find.byValueKey('RotorPosition.3'));

    // Rotate rotor 1 forward (A to B)
    await driver?.tap(plusButtonRotor1);
    getRotorPosition(1); // B
    await driver?.waitFor(find.byValueKey('RotorPosition.1'));

    // Reset
    await driver?.tap(minusButtonRotor1);

    // Rotate rotor 1 A to Z
    await driver?.tap(minusButtonRotor1);
    await getRotorPosition(1); // Z
    await driver?.waitFor(find.byValueKey('RotorPosition.1'));


    // Rotate rotor 3 A to C
    await driver?.tap(plusButtonRotor3);
    await driver?.tap(plusButtonRotor3);
    await getRotorPosition(3);
    await driver?.waitFor(find.byValueKey('RotorPosition.3'), timeout: const Duration(seconds: 10),
    );

    // Rotate rotor 3 A to X
    await driver?.tap(minusButtonRotor3);
    await driver?.tap(minusButtonRotor3);
    await driver?.tap(minusButtonRotor3);
    await getRotorPosition(3);
    await driver?.waitFor(find.byValueKey('RotorPosition.3'), timeout: const Duration(seconds: 10),
    );

  });
}