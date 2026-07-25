import 'package:flutter_test/flutter_test.dart';
import 'package:ordertracker/models/order.dart';

void main() {
  group('Order Model Tests', () {
    test('Order.fromJson correctly parses valid json with raw string items', () {
      final json = {
        'id': '201',
        'customer': 'Alice Smith',
        'items': 'Wireless Mouse, Mechanical Keyboard',
        'amount': 150.50,
        'status': 'Processing',
        'placed_at': '2026-07-24T10:00:00Z',
      };

      final order = Order.fromJson(json);

      expect(order.id, equals('201'));
      expect(order.customer, equals('Alice Smith'));
      expect(order.amount, equals(150.50));
      expect(order.status, equals('Processing'));
      expect(order.normalizedStatus, equals('Processing'));
      expect(order.itemsList.length, equals(2));
      expect(order.formattedAmount, equals('₹150.50'));
    });

    test('Order.fromJson correctly normalizes status strings', () {
      final orderPending = Order.fromJson({'id': '1', 'status': '  PENDING  '});
      final orderShipped = Order.fromJson({'id': '2', 'status': 'shipped_out'});
      final orderDelivered = Order.fromJson({'id': '3', 'status': 'Delivered Successfully'});
      final orderCancelled = Order.fromJson({'id': '4', 'status': 'CANCELLED_BY_USER'});

      expect(orderPending.normalizedStatus, equals('Pending'));
      expect(orderShipped.normalizedStatus, equals('Shipped'));
      expect(orderDelivered.normalizedStatus, equals('Delivered'));
      expect(orderCancelled.normalizedStatus, equals('Cancelled'));
    });

    test('OrderItem.fromJson correctly parses item data', () {
      final json = {
        'name': 'USB-C Cable',
        'quantity': 3,
        'price': 12.99,
      };

      final item = OrderItem.fromJson(json);

      expect(item.name, equals('USB-C Cable'));
      expect(item.quantity, equals(3));
      expect(item.price, equals(12.99));
    });
  });
}
