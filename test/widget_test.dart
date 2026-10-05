import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamacare/screens/antenatal/antenatal_screen.dart';

void main() {
  testWidgets('Antenatal screen smoky layout validation test', (WidgetTester tester) async {
    // Mount the widget tree
    await tester.pumpWidget(const MaterialApp(
      home: AntenatalScreen(),
    ));

    // Verify that the view renders the circular progress loader or standard text frames
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
