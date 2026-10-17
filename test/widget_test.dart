import 'package:fitness_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('PrimaryButton shows label and handles tap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: PrimaryButton(label: 'Go', onPressed: () => tapped = true),
      ),
    );
    await tester.tap(find.text('Go'));
    expect(tapped, isTrue);
  });
}
