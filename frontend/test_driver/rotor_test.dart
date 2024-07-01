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

    // Reset
    await driver?.tap(minusButtonRotor3);
    await driver?.tap(minusButtonRotor3);

    // Rotate rotor 3 A to X
    await driver?.tap(minusButtonRotor3);
    await driver?.tap(minusButtonRotor3);
    await driver?.tap(minusButtonRotor3);
    await checkValue(rotorPosition3, "X");
  });

  test("Change rotors", timeout: const Timeout(Duration(seconds: 60)),
      () async {
    await login(driver);
    await resetSelectedMachine(driver);

    // set rotor 1
    final dropdown1 = find.byValueKey("DropDown.1");
    await driver?.tap(dropdown1);
    final item1 = find.byValueKey("Item.1.5");
    await driver?.tap(item1);

    // set rotor 2
    final dropdown2 = find.byValueKey("DropDown.2");
    await driver?.tap(dropdown2);
    final item2 = find.byValueKey("Item.2.2");
    await driver?.tap(item2);

    // set rotor 3
    final dropdown3 = find.byValueKey("DropDown.3");
    await driver?.tap(dropdown3);
    final item3 = find.byValueKey("Item.3.4");
    await driver?.tap(item3);

    // check notches
    final notch1 = find.byValueKey("Notch.1");
    await checkValue(notch1, "H");
    final notch2 = find.byValueKey("Notch.2");
    await checkValue(notch2, "M");
    final notch3 = find.byValueKey("Notch.3");
    await checkValue(notch3, "R");

    // type on keyboard
    final text =
        "Lorem ipsum dolor sit amet consetetur sadipscing elitr".split("");
    final encText =
        "sycgk ajert giiss lss uvws bdkvzspvka kjueouflwq ignqv".split("");
    for (int i = 0; i < text.length; i++) {
      if (text[i] == " ") continue;

      await writeChar(text[i], driver);
      final combo = '${text[i].toUpperCase()} → ${encText[i].toUpperCase()}';

      await driver?.waitFor(
        find.text(combo),
        timeout: const Duration(seconds: 3),
      );
    }

    await logout(driver);
  });

  test("Change ukw", timeout: const Timeout(Duration(seconds: 30)), () async {
    await login(driver);
    await resetSelectedMachine(driver);

    // set to ukw-c
    final dropdown = find.byValueKey("DropDownReflector");
    await driver?.tap(dropdown);
    final item = find.byValueKey("Item.ukw-c");
    await driver?.tap(item);

    // type on keyboard
    final text = "lorem ipsum dolor sit amet".split("");
    final encText = "mrfxu amgax unkuf tzk vurn".split("");
    for (int i = 0; i < text.length; i++) {
      if (text[i] == " ") continue;

      await writeChar(text[i], driver);
      final combo = '${text[i].toUpperCase()} → ${encText[i].toUpperCase()}';

      await driver?.waitFor(
        find.text(combo),
        timeout: const Duration(seconds: 3),
      );
    }

    await logout(driver);
  });
}
