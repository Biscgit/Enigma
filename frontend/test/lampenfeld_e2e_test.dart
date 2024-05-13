import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:enigma/lampenfeld.dart';

void main() {
  testWidgets('LampPanel E2E test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    Lampfield lampfield = const Lampfield();
    await tester.pumpWidget(lampfield);

    //await tester.tap(find.byType(TextField)); //Might be useful at some point
    //await tester.pump();

    // TEST WITHOUT ANY INPUTS

    expect(find.byWidgetPredicate((widget) {
      // 1: At the start, all 26 lamps are grey.
      if (widget is CircularTextBox) {
        final finder = find.byKey(widget.key!);
        final state = tester.state<CircularTextBoxState>(finder);
        return state.colorBox == Colors.grey;
      }
      return false;
    }), findsExactly(26));
    expect(find.byWidgetPredicate((widget) {
      // 0 lamps are highlighted, therefore.
      if (widget is CircularTextBox) {
        final finder = find.byKey(widget.key!);
        final state = tester.state<CircularTextBoxState>(finder);
        return state.colorBox == Colors.yellow;
      }
      return false;
    }),
        findsExactly(
            0)); //This also now ensures that exactly 26 lamps were generated.

    // TEST INPUT A:

    final LampfieldState lampfieldstateFor1 =
        tester.state(find.byType(Lampfield));

    await lampfieldstateFor1.sendTextInputToLampfieldAsync("A");
    await tester.pump();

    expect(find.byWidgetPredicate((widget) {
      //Only one key should be highlighted.
      if (widget is CircularTextBox) {
        final finder = find.byKey(widget.key!);
        final state = tester.state<CircularTextBoxState>(finder);
        return widget.text == "A" && state.colorBox == Colors.yellow;
      }
      return false;
    }), findsOne);

    // TEST INPUT WITH TWO LETTERS:

    final LampfieldState lampfieldstateFor2 =
        tester.state(find.byType(Lampfield));

    await lampfieldstateFor2.sendTextInputToLampfieldAsync("Hi");
    await tester.pump();

    expect(find.byWidgetPredicate((widget) {
      //Only one key should be highlighted.
      if (widget is CircularTextBox) {
        final finder = find.byKey(widget.key!);
        final state = tester.state<CircularTextBoxState>(finder);
        return widget.text == "I" && state.colorBox == Colors.yellow;
      }
      return false;
    }), findsOne);

    // TEST INPUT WITH THREE LETTERS:

    final LampfieldState lampfieldstateFor3 =
        tester.state(find.byType(Lampfield));

    await lampfieldstateFor3.sendTextInputToLampfieldAsync("Lol");
    await tester.pump();

    expect(find.byWidgetPredicate((widget) {
      //Only one key should be highlighted.
      if (widget is CircularTextBox) {
        final finder = find.byKey(widget.key!);
        final state = tester.state<CircularTextBoxState>(finder);
        return widget.text == "L" && state.colorBox == Colors.yellow;
      }
      return false;
    }), findsOne);

    // TEST INPUT WITH MANY LETTERS:

    final LampfieldState lampfieldstateForX =
        tester.state(find.byType(Lampfield));

    await lampfieldstateForX.sendTextInputToLampfieldAsync(
        "hiThisIsALongInputButWeSadlyCannotUseAnySpacebarsOrSpecialCharactersOrDigitsBecauseTheEnigmaMachineDoesntAllowForThat");
    await tester.pump();

    expect(find.byWidgetPredicate((widget) {
      //? Doesnt highlight a key => No key should be highlighted now
      if (widget is CircularTextBox) {
        final finder = find.byKey(widget.key!);
        final state = tester.state<CircularTextBoxState>(finder);
        return state.colorBox == Colors.yellow;
      }
      return false;
    }), findsOne);
  });
}
