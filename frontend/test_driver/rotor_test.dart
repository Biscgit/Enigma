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

  //tests

}