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
  final resetButton = find.byValueKey("ResetButton");
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

Future<void> createMachine(FlutterDriver? driver, String name, bool plugboardOn, int rotorCount, List<int> rotorList, List<int> uKWList) async {
  //rotorCount > 0; rotorList only contains elements in [1; 18]
  
  if(rotorCount <= 0) {
    return;
  }
  
  final addButton = find.byValueKey('addButton');
  await driver?.tap(addButton);

  final nameTextfield = find.byValueKey("AddMachine-Key-Name");
  await driver?.waitFor(nameTextfield, timeout: const Duration(seconds: 10));
  await driver?.tap(nameTextfield);
  await driver?.enterText(name);

  var plugboardSwitch = find.byValueKey("AddMachine-Key-Plugboard");
  await driver?.tap(plugboardSwitch);
  await driver?.tap(plugboardSwitch);
  await driver?.tap(plugboardSwitch); //On, off, on
  if(!plugboardOn) {
    await driver?.tap(plugboardSwitch); //off again
  }
  
  final rotorTextfield = find.byValueKey("AddMachine-Key-RotorNr");
  await driver?.tap(rotorTextfield);
  await driver?.enterText(rotorCount.toString());

  for(int i in rotorList) {
    await driver?.scrollUntilVisible(find.byValueKey("SingleChildScrollView-Key-Hier Rotoren auswählen"), find.byValueKey("Checkbox-Key-Rotor $i"), dyScroll: -1000000.0);
    await driver?.tap(find.byValueKey("Checkbox-Key-Rotor $i"));
  }
  await driver?.scrollUntilVisible(find.byValueKey("SingleChildScrollView-Key-Hier Rotoren auswählen"), find.byValueKey("BottomButton-Hier Rotoren auswählen"), dyScroll: -1000000.0);
  await driver?.tap(find.byValueKey("BottomButton-Hier Rotoren auswählen"));

  for(int x in uKWList) {
    String ukwKey = "";
    if(x == 0) {
      ukwKey = "-A";
    }
    else if(x == 1) {
      ukwKey = "-B";
    }
    else if(x == 2) {
      ukwKey = "-C";
    }
    else if(x == 3) {
      ukwKey = "-D*";
    }
    /*
    else if(x == 4) {
      ukwKey = "";
    }
    */

    await driver?.scrollUntilVisible(
        find.byValueKey("SingleChildScrollView-Key-Hier UKWs auswählen"),
        find.byValueKey("Checkbox-Key-UKW$ukwKey"),
        dyScroll: -1000000.0);
    await driver?.tap(find.byValueKey("Checkbox-Key-UKW$ukwKey"));

    await driver?.scrollUntilVisible(
        find.byValueKey("SingleChildScrollView-Key-Hier UKWs auswählen"),
        find.byValueKey("BottomButton-Hier UKWs auswählen"),
        dyScroll: -1000000.0);
    await driver?.tap(find.byValueKey("BottomButton-Hier UKWs auswählen"));
  }
}

Future<void> selectMachineByName(FlutterDriver? driver, String name) async {
  final drawerButton = find.byTooltip('Open navigation menu');
  await driver?.tap(drawerButton);

  final machine = find.text(name);
  await driver?.waitFor(machine);
  await driver?.tap(machine);

  await driver?.waitUntilNoTransientCallbacks(
      timeout: const Duration(seconds: 3));
}

Future<void> createSimpleMachine(FlutterDriver? driver, String machineName,
    bool plugboard, {int offset = 1}) async {
  await driver?.tap(find.byValueKey('addButton'));
  await driver?.waitUntilNoTransientCallbacks(
      timeout: const Duration(seconds: 3));

  // name and rotor count
  await driver?.tap(find.byValueKey("AddMachine-Key-Name"));
  await driver?.enterText(machineName);
  await driver?.tap(find.byValueKey("AddMachine-Key-RotorNr"));
  await driver?.enterText("3");

  // plugboard
  if (plugboard) {
    await driver?.tap(find.byValueKey("AddMachine-Key-Plugboard"));
  }

  // ukw
  await driver?.tap(find.byValueKey("AddMachine-Key-UKWList"));
  await driver?.tap(find.byValueKey("Checkbox-Key-UKW-A"));
  final closeUKWSelect = find.byValueKey("BottomButton-Hier UKWs auswählen");
  await driver?.tap(closeUKWSelect);

  // rotors
  await driver?.tap(find.byValueKey("AddMachine-Key-RotorList"));
  await driver?.tap(find.byValueKey("Checkbox-Key-Rotor $offset"));
  final closeRotorSelect =
      find.byValueKey("BottomButton-Hier Rotoren auswählen");
  await driver?.scrollUntilVisible(
    find.byValueKey("SingleChildScrollView-Key-Hier Rotoren auswählen"),
    closeRotorSelect,
    dyScroll: -1000,
  );
  await driver?.tap(closeRotorSelect);

  // create
  await driver?.tap(find.byValueKey("AddMachine-Key-Confirm"));
  await driver?.waitUntilNoTransientCallbacks(
      timeout: const Duration(seconds: 3));
}

Future<void> deleteMachine(FlutterDriver? driver, String name) async {
  await selectMachineByName(driver, name);

  await driver?.waitFor(find.byValueKey("deleteButton"));
  await driver?.tap(find.byValueKey("deleteButton"));

  final confirmFirst = find.byValueKey("YesButtonDeletePopup");
  await driver?.waitFor(confirmFirst, timeout: const Duration(seconds: 3));
  await driver?.tap(confirmFirst);

  final confirmFinal = find.byValueKey("OKButtonDeleteFinal");
  await driver?.waitFor(confirmFinal, timeout: const Duration(seconds: 3));
  await driver?.tap(confirmFinal);

  await driver?.waitUntilNoTransientCallbacks(
      timeout: const Duration(seconds: 3));
}
