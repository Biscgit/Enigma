import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:enigma/lampenfeld.dart';

void main() {
  testWidgets('Lamppanel E2E test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    Lampfield lampfield = Lampfield();
    await tester.pumpWidget(lampfield);

    //await tester.tap(find.byType(TextField)); //Might be useful at some point
    //await tester.pump();

    // TEST WITHOUT ANY INPUTS

    expect(find.byWidgetPredicate((widget) { // 1: At the start, all 26 lamps are grey.
      if (widget is CircularTextBox) {
        final finder = find.byKey(widget.key!);
        final state = tester.state<CircularTextBoxState>(finder);
        return state.colorBox == Colors.grey;
      }
      return false;
    }), findsExactly(26));
    expect(find.byWidgetPredicate((widget) { // 0 lamps are highlighted, therefore.
      if (widget is CircularTextBox) {
        final finder = find.byKey(widget.key!);
        final state = tester.state<CircularTextBoxState>(finder);
        return state.colorBox == Colors.yellow;
      }
      return false;
    }), findsExactly(0)); //This also now ensures that exactly 26 lamps were generated.



    // TEST INPUT A:

    await lampfield.currentState!.sendTextInputToLampfieldAsync("A");
    await tester.pump();

    expect(find.byWidgetPredicate((widget) { //Only one key should be highlighted.
      if (widget is CircularTextBox) {
        final finder = find.byKey(widget.key!);
        final state = tester.state<CircularTextBoxState>(finder);
        return widget.text == "A" && state.colorBox == Colors.yellow;
      }
      return false;
    }), findsOne);



    // TEST INPUT WITH TWO LETTERS:

    await lampfield.currentState!.sendTextInputToLampfieldAsync("Hi");
    await tester.pump();

    expect(find.byWidgetPredicate((widget) { //Only one key should be highlighted.
      if (widget is CircularTextBox) {
        final finder = find.byKey(widget.key!);
        final state = tester.state<CircularTextBoxState>(finder);
        return widget.text == "I" && state.colorBox == Colors.yellow;
      }
      return false;
    }), findsOne);



    // TEST INPUT WITH THREE LETTERS:

    await lampfield.currentState!.sendTextInputToLampfieldAsync("Lol");
    await tester.pump();

    expect(find.byWidgetPredicate((widget) { //Only one key should be highlighted.
      if (widget is CircularTextBox) {
        final finder = find.byKey(widget.key!);
        final state = tester.state<CircularTextBoxState>(finder);
        return widget.text == "L" && state.colorBox == Colors.yellow;
      }
      return false;
    }), findsOne);



    // TEST INPUT WITH TWO LETTERS AND A SPECIAL CHARACTER:

    await lampfield.currentState!.sendTextInputToLampfieldAsync("Hi? This could also be a longer input, as long as it doesn't end on a letter. Wooo!");
    await tester.pump();

    expect(find.byWidgetPredicate((widget) { //? Doesnt highlight a key => No key should be highlighted now
      if (widget is CircularTextBox) {
        final finder = find.byKey(widget.key!);
        final state = tester.state<CircularTextBoxState>(finder);
        return state.colorBox == Colors.yellow;
      }
      return false;
    }), findsNothing);
  });
}
