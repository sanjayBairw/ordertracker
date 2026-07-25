import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ordertracker/widgets/vertical_timeline.dart';

void main() {
  group('VerticalTimeline Widget Tests', () {
    testWidgets('Renders timeline steps for active order', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VerticalTimeline(currentStatus: 'Processing'),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Order Placed'), findsOneWidget);
      expect(find.text('Processing'), findsOneWidget);
      expect(find.text('Shipped'), findsOneWidget);
      expect(find.text('Delivered'), findsOneWidget);

      // Clean up widget to stop repeating pulse animation controller
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('Renders Cancelled timeline container when status is Cancelled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerticalTimeline(currentStatus: 'Cancelled'),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Order Cancelled'), findsOneWidget);
      expect(find.byIcon(Icons.cancel_rounded), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });
  });
}
