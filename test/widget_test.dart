// This is a basic Flutter widget test.
//
// Widget tests (also called component tests) verify that individual
// widgets in your app behave as expected. You can simulate user
// interactions, read widget values, and check UI changes.
//
// This file tests that the counter in your app increments correctly.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_secure_access/main.dart'; // ✅ Make sure this matches your project name

void main() {
  testWidgets('Secure counter increments test', (WidgetTester tester) async {
    // 1️⃣ Build the app and trigger a frame.
    await tester.pumpWidget(const AISecureAccessApp());

    // 2️⃣ Verify that the initial counter value is 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // 3️⃣ Tap the fingerprint button (floating action button).
    await tester.tap(find.byIcon(Icons.fingerprint));
    await tester.pump(); // Rebuild the widget after the state change

    // 4️⃣ Verify that the counter has incremented to 1.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
