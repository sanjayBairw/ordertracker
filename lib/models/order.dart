import 'package:intl/intl.dart';

class OrderItem {
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name']?.toString() ?? 'Item',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }

  String get formattedPrice {
    try {
      final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
      return formatter.format(price * quantity);
    } catch (_) {
      return '₹${(price * quantity).toStringAsFixed(2)}';
    }
  }
}

class Order {
  final String id;
  final String customer;
  final String itemsRaw;
  final List<OrderItem> itemsList;
  final double amount;
  final String status;
  final String placedAt;

  Order({
    required this.id,
    required this.customer,
    required this.itemsRaw,
    required this.itemsList,
    required this.amount,
    required this.status,
    required this.placedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    String itemsRawStr = '';
    List<OrderItem> parsedItems = [];

    if (rawItems is String) {
      itemsRawStr = rawItems;
      if (itemsRawStr.contains(',')) {
        final split = itemsRawStr.split(',');
        parsedItems = split.map((s) => OrderItem(name: s.trim(), quantity: 1, price: 0)).toList();
      } else if (itemsRawStr.isNotEmpty) {
        parsedItems = [OrderItem(name: itemsRawStr.trim(), quantity: 1, price: 0)];
      }
    } else if (rawItems is List) {
      parsedItems = rawItems.map((e) {
        if (e is Map<String, dynamic>) {
          return OrderItem.fromJson(e);
        } else {
          return OrderItem(name: e.toString(), quantity: 1, price: 0);
        }
      }).toList();
      itemsRawStr = parsedItems.map((e) => "${e.quantity}x ${e.name}").join(', ');
    }

    return Order(
      id: json['id']?.toString() ?? '',
      customer: json['customer']?.toString() ?? 'Guest Customer',
      itemsRaw: itemsRawStr.isNotEmpty ? itemsRawStr : 'Standard Order Items',
      itemsList: parsedItems.isNotEmpty ? parsedItems : [OrderItem(name: 'Item Package', quantity: 1, price: (json['amount'] as num?)?.toDouble() ?? 0.0)],
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'Pending',
      placedAt: json['placed_at']?.toString() ?? json['placedAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer': customer,
      'items': itemsRaw,
      'amount': amount,
      'status': status,
      'placed_at': placedAt,
    };
  }

  String get formattedOrderId {
    final clean = id.trim().toUpperCase();
    if (clean.startsWith('ORD-')) return clean;
    final numVal = int.tryParse(clean);
    if (numVal != null) {
      if (numVal < 1000) {
        return "ORD-${1000 + numVal}";
      }
      return "ORD-$numVal";
    }
    return 'ORD-$clean';
  }

  String get formattedDate {
    try {
      final dateTime = DateTime.parse(placedAt);
      return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
    } catch (_) {
      return placedAt;
    }
  }

  String get formattedAmount {
    try {
      final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
      return formatter.format(amount);
    } catch (_) {
      return '₹${amount.toStringAsFixed(2)}';
    }
  }

  String get normalizedStatus {
    final lower = status.trim().toLowerCase();
    if (lower.contains('pend')) return 'Pending';
    if (lower.contains('process')) return 'Processing';
    if (lower.contains('ship')) return 'Shipped';
    if (lower.contains('deliver')) return 'Delivered';
    if (lower.contains('cancel')) return 'Cancelled';
    return status.isNotEmpty ? status : 'Pending';
  }
}