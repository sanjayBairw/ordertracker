import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ordertracker/widgets/status_chip.dart';

void main() {
  group('StatusChip Widget Tests', () {
    testWidgets('Renders Pending status chip correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusChip(status: 'Pending'),
          ),
        ),
      );

      expect(find.text('Pending'), findsOneWidget);
      expect(find.byIcon(Icons.schedule_rounded), findsOneWidget);
    });

    testWidgets('Renders Shipped status chip correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusChip(status: 'Shipped'),
          ),
        ),
      );

      expect(find.text('Shipped'), findsOneWidget);
      expect(find.byIcon(Icons.local_shipping_rounded), findsOneWidget);
    });

    testWidgets('Renders Cancelled status chip correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusChip(status: 'Cancelled'),
          ),
        ),
      );

      expect(find.text('Cancelled'), findsOneWidget);
      expect(find.byIcon(Icons.cancel_rounded), findsOneWidget);
    });
  });
}
