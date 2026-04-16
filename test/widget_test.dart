import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wego_marriage/screen/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the splash screen shows the app name.
    expect(find.text('WeGo\nMarriage'), findsOneWidget);
    expect(find.text('Matrimonial App'), findsOneWidget);
  });
}
