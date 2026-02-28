// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lanka_law/main.dart';
import 'package:lanka_law/screen_widgets/home_screen.dart';

void main() {
  testWidgets('Dashboard renders smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    // Verify that the title and services section are present.
    expect(find.text('LankaLAW'), findsOneWidget);
    expect(find.text('Services'), findsOneWidget);
    expect(find.text('Daily Legal Tip'), findsOneWidget);
  });
}
