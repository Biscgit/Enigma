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


  test("Test cancel button", timeout: const Timeout(Duration(seconds: 30)),
    () async {
      await login(driver);
      await pressSidebar(driver);

      final cancelButton = find.byValueKey("AddMachine-Key-Cancel"); // Test cancel button
      await driver?.waitFor(cancelButton, timeout: const Duration(seconds: 5));
      await driver?.tap(cancelButton);
  });

  test("Create new machine", timeout: const Timeout(Duration(seconds: 180)),
    () async {
      await login(driver);
      await pressSidebar(driver);

      await enterName(driver);
      print("Name entered.");
      await togglePlugboard(driver);
      print("Plugboard tested.");
      await rotorNrTesting(driver);
      print("Amount of rotors entered.");
      await selectRotors(driver);
      print("Rotors selected.");
      await selectUKW(driver);
    });
  

  /*test("Test new machine", timeout: const Timeout(Duration(minutes: 1)),
    () async {
      await login(driver);
      await pressSidebar(driver);

      var sidebarKey = find.byType("SideBar");
      await driver?.tap(sidebarKey);

      var createdMachine = const ByText("This is a test machine.");
      await driver?.tap(createdMachine);
  });*/
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
Future<void> pressSidebar(FlutterDriver? driver) async {
  var addButton = find.byValueKey('addButton');
  await driver?.tap(addButton);
}

Future<void> selectRotors(FlutterDriver? driver) async {
  // Test rotor selection list

  final rotorSelectorMenu = find.byValueKey("AddMachine-Key-RotorList");
  await driver?.tap(rotorSelectorMenu);

  final rotor1 = find.byValueKey("Checkbox-Key-Rotor 1");
  final rotor3 = find.byValueKey("Checkbox-Key-Rotor 3");
  final rotor16 = find.byValueKey("Checkbox-Key-Rotor 16");
  await driver?.tap(rotor1);
  await driver?.tap(rotor3);
  await driver?.tap(rotor16);

  // Test that if you click now, it doesnt work

  final confirmKey = find.byValueKey("AddMachine-Key-Confirm");
  await driver?.tap(confirmKey); // Nothing should happen here
}

Future<void> selectUKW(FlutterDriver? driver) async {

  final uKWSelectorMenu = find.byValueKey("AddMachine-Key-UKWList");
  await driver?.tap(uKWSelectorMenu);

  final uKWA = find.byValueKey("Checkbox-Key-UKW-A");
  final uKWB = find.byValueKey("Checkbox-Key-UKW-B");
  final uKWC = find.byValueKey("Checkbox-Key-UKW-C");
  final uKWDAsterisk = find.byValueKey("Checkbox-Key-UKW-D*");
  final uKWNoname = find.byValueKey("Checkbox-Key-UKW");

  await driver?.tap(uKWA);
  await driver?.tap(uKWB);
  await driver?.tap(uKWC);
  await driver?.tap(uKWDAsterisk);
  await driver?.tap(uKWNoname);

  final confirmKey = find.byValueKey("AddMachine-Key-Confirm");
  await driver?.tap(confirmKey);
}

Future<void> rotorNrTesting(FlutterDriver? driver) async {
      final rotorTextfield = find.byValueKey("AddMachine-Key-RotorNr");
      /*await driver?.tap(rotorTextfield);
      await driver?.enterText("0112233445566778997");
      String? enteredAmount = await driver?.getText(rotorTextfield); // This should never be null
      assert(enteredAmount! == "7");*/
      // This will be null because it doesn't enter the digits one-by-one but copy-and-pastes
      // the whole number which is greater than 7 (112233445566778997 > 7)

      await driver?.tap(rotorTextfield);
      await driver?.enterText("0");
      String? enteredAmount = await driver?.getText(rotorTextfield); // This should be null
      assert(enteredAmount == null);
  
      await driver?.tap(rotorTextfield);
      await driver?.enterText("8");
      enteredAmount = await driver?.getText(rotorTextfield); // This should be null
      assert(enteredAmount == null);
      
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
}