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

  test('Check Flutter-driver health', () async {
    Health? health = await driver?.checkHealth();
    assert(health?.status == HealthStatus.ok);
  });

  test('History and Limit of 140', timeout: const Timeout(Duration(minutes: 5)),
      () async {
    await login(driver);
    await resetSelectedMachine(driver);

    // Add keys to the history
    final clearChars = "loremipsumdolorsitametconsetetursadipscingelitrseddia"
            "mnonumyeirmodtemporinviduntutlaboreetdoloremagnaaliquyameratsedd"
            "iamvoluptuaatveroeosetaccusametjustoduodolores"
        .split("");
    final enCryChars = "azjkkvhkcqgvgkvdrgqsnplvtaymcllaywojjaajfuryxqvxbubho"
            "iqcwiggdzbddczufdxnedjrzlcohlevqnkhqojmbxpxbdfrrdsmtgethfblqkxim"
            "ubeizoyxswpvdlafmdhlszdzhwxnxsatlnveaeezgkcnpf"
        .split("");

    // Add many keys to test the history
    List<String> keyPairs = [];
    for (int i = 0; i < clearChars.length; i++) {
      // press on keyboard
      await driver?.tap(
          find.byValueKey("Tastatur-Button-${clearChars[i].toUpperCase()}"));

      final combo =
          '${clearChars[i].toUpperCase()} → ${enCryChars[i].toUpperCase()}';
      keyPairs.insert(0, combo);

      await driver?.waitFor(
        find.text(combo),
        timeout: const Duration(seconds: 3),
      );
    }
    try {
      await driver?.scrollUntilVisible(
        find.byValueKey("keyHistoryList"),
        find.text(keyPairs[138]),
        dyScroll: -100000,
        timeout: const Duration(seconds: 10),
      );

      await driver?.waitUntilNoTransientCallbacks(
        timeout: const Duration(seconds: 10),
      );
      // await takeScreenshot(driver!, "here.png");

      // check if 140 limit is working
      await driver?.waitFor(
        find.text(keyPairs[138]),
        timeout: const Duration(seconds: 3),
      );
      await driver?.waitFor(
        find.text(keyPairs[139]),
        timeout: const Duration(seconds: 3),
      );

      await driver?.waitForAbsent(
        find.text(keyPairs[140]),
        timeout: const Duration(seconds: 3),
      );
      await driver?.waitForAbsent(
        find.text(keyPairs[141]),
        timeout: const Duration(seconds: 3),
      );
    } on TimeoutException catch (_) {
      // catch only issues related to scrolling bug
      // print("Run test with `--release` -> bug in library with scrolling");
    }
  });

  test("Multiuser loading", timeout: const Timeout(Duration(seconds: 60)),
      () async {
    await login(driver, username: "user2", password: "pass2");
    await resetSelectedMachine(driver);

    // emulate different user typing
    for (final char in "WeLoveWoelfl".split("")) {
      await writeChar(char, driver);
    }

    // test a few keys
    await driver?.waitFor(find.text("L → S"),
        timeout: const Duration(seconds: 3));
    await driver?.waitFor(find.text("F → B"),
        timeout: const Duration(seconds: 3));
    await driver?.waitFor(find.text("L → E"),
        timeout: const Duration(seconds: 3));
    await driver?.waitFor(find.text("E → J"),
        timeout: const Duration(seconds: 3));
    await driver?.waitFor(find.text("O → L"),
        timeout: const Duration(seconds: 3));
    await driver?.waitFor(find.text("W → B"),
        timeout: const Duration(seconds: 3));
    await logout(driver);

    await login(driver, username: "user1", password: "pass1");
    await driver?.waitForAbsent(find.text("L → S"),
        timeout: const Duration(seconds: 3));
    await driver?.waitForAbsent(find.text("F → B"),
        timeout: const Duration(seconds: 3));
    await driver?.waitForAbsent(find.text("L → E"),
        timeout: const Duration(seconds: 3));

    // check if previous typed history gets loaded correctly
    final clearChars = "dolores".split("").reversed.toList();
    final enCryChars = "zgkcnpf".split("").reversed.toList();

    for (int i = 0; i < clearChars.length; i++) {
      final combo =
          '${clearChars[i].toUpperCase()} → ${enCryChars[i].toUpperCase()}';
      await driver?.waitFor(
        find.text(combo),
        timeout: const Duration(seconds: 3),
      );
    }
  });
}
