import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ordertracker/main.dart';

void main() {
  testWidgets('Order Tracker App smoke test', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        const ProviderScope(
          child: OrderTrackerApp(),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 200));
    });

    await tester.pumpAndSettle();

    expect(find.text('Order Tracker'), findsWidgets);
  });
}
