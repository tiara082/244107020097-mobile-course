import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week1/main.dart';

void main() {
  testWidgets('Student Profile App loading test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StudentProfileApp());

    // Verify that the title 'Student Profile' is displayed.
    expect(find.text('Student Profile'), findsOneWidget);

    // Verify that the student ID (NIM) is displayed.
    expect(find.textContaining('244107020097'), findsAtLeast(1));

    // Verify that the student Name is displayed.
    expect(find.text('Tiara Febrianie'), findsOneWidget);

    // Verify that the theme toggle is present (Icon button).
    expect(find.byType(IconButton), findsAtLeast(1));
  });
}
