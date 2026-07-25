import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ordertracker/models/order.dart';
import 'package:ordertracker/widgets/order_card.dart';

void main() {
  group('OrderCard Widget Tests', () {
    final testOrder = Order(
      id: '1',
      customer: 'Alex Rivera',
      itemsRaw: 'Wireless Headphones, Protective Case',
      itemsList: [
        OrderItem(name: 'Wireless Headphones', quantity: 1, price: 14999.00),
      ],
      amount: 16998.00,
      status: 'Delivered',
      placedAt: '2026-07-24T10:30:00Z',
    );

    testWidgets('Renders OrderCard with ORD-1001 format and INR currency symbol', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OrderCard(
              order: testOrder,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Order #ORD-1001'), findsOneWidget);
      expect(find.text('Alex Rivera'), findsOneWidget);
      expect(find.text('Delivered'), findsOneWidget);
      expect(find.text('₹16,998.00'), findsOneWidget);
    });

    testWidgets('Triggers onTap callback when OrderCard is tapped', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OrderCard(
              order: testOrder,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(OrderCard));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });
}
