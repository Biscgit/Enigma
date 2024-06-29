import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'test_lib.dart';
import 'tastatur_test.dart' as tt;

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


  test("Test cancel button", timeout: const Timeout(Duration(seconds: 30)),
    () async {
      await login(driver);
      await pressAddButton(driver);

      final cancelButton = find.byValueKey("AddMachine-Key-Cancel"); // Test cancel button
      await driver?.waitFor(cancelButton, timeout: const Duration(seconds: 5));
      await driver?.tap(cancelButton);
  });

  test("Create new machine", timeout: const Timeout(Duration(seconds: 180)),
    () async {
      await login(driver);
      await pressAddButton(driver);

      await enterName(driver);
      await togglePlugboard(driver);
      await rotorNrTestingNoRegEx(driver, 0);
      await selectRotors(driver);
      // Test that if you click now, it doesnt work
      final confirmKey = find.byValueKey("AddMachine-Key-Confirm");
      await driver?.tap(confirmKey); // Nothing should happen here because UKWs are not yet selected
      final cantCreateMachineSoPressOKKey = find.byValueKey("AddMachine-Cant-Create-OK");
      await driver?.tap(cantCreateMachineSoPressOKKey);
      await selectUKW(driver);
      await driver?.tap(confirmKey); // Nothing should happen here because 0 rotors are entered
      await driver?.tap(cantCreateMachineSoPressOKKey);
      await rotorNrTestingNoRegEx(driver, 69); // haha 69
      await driver?.tap(confirmKey); // Now it should work.
    });
  

  test("Test new machine", timeout: const Timeout(Duration(seconds: 180)),
    () async {
      await login(driver);
      final drawerButton = find.byTooltip('Open navigation menu');
      await driver?.tap(drawerButton);

      final createdMachine = find.byValueKey("sidebar.This is a test machine.");
      await driver?.tap(createdMachine);

      await Future.delayed(const Duration(seconds: 5)); // Give some time to load

      await tt.checkForKeyInput(driver, "H", "N");
      await tt.checkForKeyInput(driver, "E", "C");
      await tt.checkForKeyInput(driver, "L", "B");
      await tt.checkForKeyInput(driver, "L", "U");
      await tt.checkForKeyInput(driver, "O", "R");

      await tt.checkForKeyInput(driver, "W", "C");
      await tt.checkForKeyInput(driver, "O", "A");
      await tt.checkForKeyInput(driver, "R", "P");
      await tt.checkForKeyInput(driver, "L", "S");
      await tt.checkForKeyInput(driver, "D", "H");
  });

  test("Delete machine", timeout: const Timeout(Duration(seconds: 60)),
    () async {
      await login(driver);

      final drawerButton = find.byTooltip('Open navigation menu');
      await driver?.tap(drawerButton);

      final createdMachine = find.byValueKey("sidebar.This is a test machine.");
      await driver?.tap(createdMachine);

      final deleteButton = find.byValueKey("deleteButton");
      await driver?.tap(deleteButton);

      final confirmFirst = find.byValueKey("YesButtonDeletePopup");
      await driver?.tap(confirmFirst);
      final confirmFinal = find.byValueKey("OKButtonDeleteFinal");
      await driver?.tap(confirmFinal);

      final enigma1 = await driver?.getText(find.byValueKey("AppbarTitle"));
      assert(enigma1 == "Enigma I");
    });
}
Future<void> enterName(FlutterDriver? driver) async {
  final nameTextfield = find.byValueKey("AddMachine-Key-Name");
  await driver?.waitFor(nameTextfield, timeout: const Duration(seconds: 10));
  await driver?.tap(nameTextfield);
  await driver?.enterText("This is a test machine.");
}

Future<void> togglePlugboard(FlutterDriver? driver) async {
  // Test plugboard a little bit

  var plugboardSwitch = find.byValueKey("AddMachine-Key-Plugboard");
  await driver?.tap(plugboardSwitch);
  await driver?.tap(plugboardSwitch);
  await driver?.tap(plugboardSwitch); //On, off, on
    
}
Future<void> pressAddButton(FlutterDriver? driver) async {
  var addButton = find.byValueKey('addButton');
  await driver?.tap(addButton);
}

Future<void> selectRotors(FlutterDriver? driver) async {
  // Test rotor selection list

  final rotorSelectorMenu = find.byValueKey("AddMachine-Key-RotorList");
  final singleChildDing = find.byValueKey("SingleChildScrollView-Key-Hier Rotoren auswählen");
  final closingKey = find.byValueKey("BottomButton-Hier Rotoren auswählen");
  await driver?.tap(rotorSelectorMenu);

  final rotor1 = find.byValueKey("Checkbox-Key-Rotor 1");
  final rotor3 = find.byValueKey("Checkbox-Key-Rotor 3");
  final rotor16 = find.byValueKey("Checkbox-Key-Rotor 16");
  await driver?.scrollUntilVisible(singleChildDing, rotor1, dyScroll: -100000.0);
  await driver?.tap(rotor1);
  await driver?.scrollUntilVisible(singleChildDing, rotor3, dyScroll: -100000.0);
  await driver?.tap(rotor3);
  await driver?.scrollUntilVisible(singleChildDing, rotor16, dyScroll: -100000.0);
  await driver?.tap(rotor16);
  await driver?.scrollUntilVisible(singleChildDing, closingKey, dyScroll: -100000.0);
  await driver?.tap(closingKey);
}

Future<void> selectUKW(FlutterDriver? driver) async {

  final uKWSelectorMenu = find.byValueKey("AddMachine-Key-UKWList");
  final closingKey = find.byValueKey("BottomButton-Hier UKWs auswählen");
  final singleChildDing = find.byValueKey("SingleChildScrollView-Key-Hier UKWs auswählen");
  await driver?.tap(uKWSelectorMenu);

  final uKWA = find.byValueKey("Checkbox-Key-UKW-A");
  final uKWB = find.byValueKey("Checkbox-Key-UKW-B");
  final uKWC = find.byValueKey("Checkbox-Key-UKW-C");
  final uKWDAsterisk = find.byValueKey("Checkbox-Key-UKW-D*");
  final uKWNoname = find.byValueKey("Checkbox-Key-UKW");

  await driver?.scrollUntilVisible(singleChildDing, uKWA, dyScroll: -100000.0);
  await driver?.tap(uKWA);
  await driver?.scrollUntilVisible(singleChildDing, uKWB, dyScroll: -100000.0);
  await driver?.tap(uKWB);
  await driver?.scrollUntilVisible(singleChildDing, uKWC, dyScroll: -100000.0);
  await driver?.tap(uKWC);
  await driver?.scrollUntilVisible(singleChildDing, uKWDAsterisk, dyScroll: -100000.0);
  await driver?.tap(uKWDAsterisk);
  await driver?.scrollUntilVisible(singleChildDing, uKWNoname, dyScroll: -100000.0);
  await driver?.tap(uKWNoname);

  await driver?.scrollUntilVisible(singleChildDing, closingKey, dyScroll: -100000.0);
  await driver?.tap(closingKey);
}

Future<void> rotorNrTestingNoRegEx(FlutterDriver? driver, int amount) async {
    final rotorTextfield = find.byValueKey("AddMachine-Key-RotorNr");
    await driver?.tap(rotorTextfield);
    await driver?.enterText(amount.toString());
    //await driver?.getText(rotorTextfield); // Throws an exception for some reason, idk
}

/*Future<void> rotorNrTesting(FlutterDriver? driver) async {
      final rotorTextfield = find.byValueKey("AddMachine-Key-RotorNr");
      late String? enteredAmount;
      await driver?.tap(rotorTextfield);
      await driver?.enterText("0112233445566778997");
      enteredAmount = await driver?.getText(rotorTextfield); // This should never be null
      assert(enteredAmount! == "7");
      // This will be null because it doesn't enter the digits one-by-one but copy-and-pastes
      // the whole number which is greater than 7 (112233445566778997 > 7)

      await driver?.tap(rotorTextfield);
      await driver?.enterText("0");
      //String? enteredAmount = await driver?.getText(rotorTextfield); // This should be null
      //assert(await driver?.getText(rotorTextfield) == null);
      try {
        enteredAmount = await driver?.getText(rotorTextfield);
        throw Exception("");
      } on Exception catch (_) {
        //This continues the test
      }
  
      await driver?.tap(rotorTextfield);
      await driver?.enterText("8");
      enteredAmount = await driver?.getText(rotorTextfield); // This should be null
      assert(await driver?.getText(rotorTextfield) == null);
      
      await driver?.tap(rotorTextfield);
      await driver?.enterText("9");
      enteredAmount = await driver?.getText(rotorTextfield); // This should be null
      assert(enteredAmount == null);
      
      await driver?.tap(rotorTextfield);
      await driver?.enterText("2");
      await driver?.enterText("2");
      enteredAmount = await driver?.getText(rotorTextfield); // This should be null
      assert(enteredAmount == null);

      await driver?.tap(rotorTextfield);
      await driver?.enterText("1");
      enteredAmount = await driver?.getText(rotorTextfield); // This should never be null
      assert(enteredAmount! == "1");
      
      await driver?.tap(rotorTextfield);
      await driver?.enterText("1"); // Removes the 1 from before because now it's > 7
      await driver?.enterText("2");
      enteredAmount = await driver?.getText(rotorTextfield); // This should never be null
      assert(enteredAmount! == "2");
      
      await driver?.tap(rotorTextfield);
      await driver?.enterText("2");
      await driver?.enterText("3");
      enteredAmount = await driver?.getText(rotorTextfield); // This should never be null
      assert(enteredAmount! == "3");
      
      await driver?.tap(rotorTextfield);
      await driver?.enterText("3");
      await driver?.enterText("4");
      enteredAmount = await driver?.getText(rotorTextfield); // This should never be null
      assert(enteredAmount! == "4");
      
      await driver?.tap(rotorTextfield);
      await driver?.enterText("4");
      await driver?.enterText("5");
      enteredAmount = await driver?.getText(rotorTextfield); // This should never be null
      assert(enteredAmount! == "5");
      
      await driver?.tap(rotorTextfield);
      await driver?.enterText("5");
      await driver?.enterText("6");
      enteredAmount = await driver?.getText(rotorTextfield); // This should never be null
      assert(enteredAmount! == "6");
      
      await driver?.tap(rotorTextfield);
      await driver?.enterText("6");
      await driver?.enterText("7");
      enteredAmount = await driver?.getText(rotorTextfield); // This should never be null
      assert(enteredAmount! == "7");
}*/