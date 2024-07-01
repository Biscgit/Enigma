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

  Future<void> checkValue(SerializableFinder item, String value) async {
    assert(await driver?.getText(item) == value);
  }

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
    final rotorPosition = find.byValueKey("RotorPosition.1");

    // initial value is Y
    await checkValue(notchKey, "Y");
    await checkValue(rotorPosition, "A");
    //await driver?.waitFor(find.text('Y'));

    // Plus button (rom Y to Z)
    await driver?.tap(plusButton);
    await checkValue(notchKey, "Z");
    await checkValue(rotorPosition, "B");
    //await driver?.waitFor(find.text('Z'));

    // Reset notch
    await driver?.tap(minusButton); // Y

    // Minus Button (From Y to X)
    await driver?.tap(minusButton);
    await checkValue(notchKey, "X");
    await checkValue(rotorPosition, "Z");
    //await driver?.waitFor(find.text('X'));
  });

  test("Rotors rotate", timeout: const Timeout(Duration(seconds: 60)),
      () async {
    await login(driver);
    await resetSelectedMachine(driver);

    final plusButtonRotor1 = find.byValueKey("ChangeRotor.1.plus");
    final minusButtonRotor1 = find.byValueKey("ChangeRotor.1.minus");
    final rotorPosition1 = find.byValueKey("RotorPosition.1");

    final plusButtonRotor3 = find.byValueKey("ChangeRotor.3.plus");
    final minusButtonRotor3 = find.byValueKey("ChangeRotor.3.minus");
    final rotorPosition3 = find.byValueKey("RotorPosition.3");

    /*Future<String?> getRotorPosition(int rotorNumber) async {
      final result = await driver?.requestData('getRotorPosition:$rotorNumber');
      return result;
    }*/

    // Initial values A
    await checkValue(rotorPosition1, "A");
    await checkValue(rotorPosition3, "A");

    // Rotate rotor 1 forward (A to B)
    await driver?.tap(plusButtonRotor1);
    await checkValue(rotorPosition1, "B");

    // Reset
    await driver?.tap(minusButtonRotor1);

    // Rotate rotor 1 A to Z
    await driver?.tap(minusButtonRotor1);
    await checkValue(rotorPosition1, "Z");

    // Rotate rotor 3 A to C
    await driver?.tap(plusButtonRotor3);
    await driver?.tap(plusButtonRotor3);
    await checkValue(rotorPosition3, "C");

    // RESET
    await driver?.tap(minusButtonRotor3);
    await driver?.tap(minusButtonRotor3);

    // Rotate rotor 3 A to X
    await driver?.tap(minusButtonRotor3);
    await driver?.tap(minusButtonRotor3);
    await driver?.tap(minusButtonRotor3);
    await checkValue(rotorPosition3, "X");
  });

  test("Change rotor 1 to 5", timeout: const Timeout(Duration(seconds: 30)),
      () async {
    await login(driver);
    await resetSelectedMachine(driver);

    final dropdown = find.byValueKey("DropDown.1");
    final item = find.byValueKey("Item.1.5");
    final notchKey = find.byValueKey("Notch.1");
    // Find dropdown from rotor 1
    await driver?.tap(dropdown);

    // Change to rotor 5
    await driver?.tap(item);

    await checkValue(notchKey, "H");

    // Notch 1 should be H after changee
    //await driver?.waitFor(find.byValueKey("Notch.1"));
    //await driver?.waitFor(find.text('H'));
  });
}
