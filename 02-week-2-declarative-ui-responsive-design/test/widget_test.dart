import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week2/main.dart';

void main() {
  testWidgets('Dashboard shows one column on a narrow screen', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const DashboardApp());
    await tester.pumpAndSettle();

    final width = tester.getSize(find.byType(Card).at(1)).width;
    expect(width, lessThan(700));
  });

  testWidgets('Dashboard shows two columns on a wide screen', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const DashboardApp());
    await tester.pumpAndSettle();

    final width = tester.getSize(find.byType(Card).at(1)).width;
    expect(width, greaterThan(500));
  });
}
