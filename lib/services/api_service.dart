import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';
import '../models/order.dart';

class FetchOrdersResponse {
  final List<Order> orders;
  final bool isOffline;
  final String? message;

  FetchOrdersResponse({
    required this.orders,
    required this.isOffline,
    this.message,
  });
}

class ApiService {
  String baseUrl;
  bool simulateError = false;

  ApiService({this.baseUrl = ApiConstants.defaultBaseUrl});

  Dio get _dio => Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: ApiConstants.connectTimeout,
          receiveTimeout: ApiConstants.receiveTimeout,
        ),
      );

  Future<FetchOrdersResponse> fetchOrdersResponse() async {
    if (simulateError) {
      final cachedOrders = await _getCachedOrders();
      if (cachedOrders.isNotEmpty) {
        return FetchOrdersResponse(
          orders: cachedOrders,
          isOffline: true,
          message: 'Simulated Offline Mode — Loaded cached orders from local storage',
        );
      }
      throw Exception('Simulated Network Exception (No internet connection & no cache available)');
    }

    try {
      final response = await _dio.get(ApiConstants.ordersEndpoint);

      List data = [];
      if (response.data is List) {
        data = response.data;
      } else if (response.data is Map && response.data.containsKey('orders')) {
        data = response.data['orders'];
      }

      final orders = List.generate(data.length, (index) {
        final itemMap = data[index] is Map<String, dynamic>
            ? Map<String, dynamic>.from(data[index] as Map)
            : <String, dynamic>{};

        final orderId = "ORD-${1000 + index + 1}";
        itemMap['id'] = orderId;

        return Order.fromJson(itemMap);
      });

      // Cache live data to SharedPreferences
      await _cacheOrders(orders);

      return FetchOrdersResponse(orders: orders, isOffline: false);
    } catch (e) {
      // Try to load cached orders if offline or API error
      final cachedOrders = await _getCachedOrders();
      if (cachedOrders.isNotEmpty) {
        return FetchOrdersResponse(
          orders: cachedOrders,
          isOffline: true,
          message: 'Network Unavailable — Displaying cached orders from local storage',
        );
      }

      // If no cache present, throw exception so UI displays full-screen offline view
      throw Exception('Network Unavailable — Could not connect to server and no cached orders were found.');
    }
  }

  Future<List<Order>> fetchOrders() async {
    final res = await fetchOrdersResponse();
    return res.orders;
  }

  Future<void> _cacheOrders(List<Order> orders) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = orders.map((o) => o.toJson()).toList();
      await prefs.setString(ApiConstants.cacheKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  Future<List<Order>> _getCachedOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(ApiConstants.cacheKey);
      if (raw != null && raw.isNotEmpty) {
        final List decoded = jsonDecode(raw);
        return decoded.map((e) => Order.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  // Seed sample 8 orders for demo / fallback with ORD-${1000 + index + 1}
  static List<Order> getSeedOrders() {
    final rawSeedData = [
      {
        'customer': 'Alex Rivera',
        'itemsRaw': 'Wireless Headphones, Protective Case',
        'itemsList': [
          OrderItem(name: 'Wireless Headphones', quantity: 1, price: 14999.00),
          OrderItem(name: 'Protective Case', quantity: 1, price: 1999.00),
        ],
        'amount': 16998.00,
        'status': 'Delivered',
        'placedAt': '2026-07-24T10:30:00Z',
      },
      {
        'customer': 'Sophia Chen',
        'itemsRaw': 'Ergonomic Office Chair',
        'itemsList': [
          OrderItem(name: 'Ergonomic Office Chair', quantity: 1, price: 29900.00),
        ],
        'amount': 29900.00,
        'status': 'Shipped',
        'placedAt': '2026-07-24T12:15:00Z',
      },
      {
        'customer': 'Marcus Johnson',
        'itemsRaw': 'Mechanical Keyboard, RGB Mousepad',
        'itemsList': [
          OrderItem(name: 'Mechanical Keyboard', quantity: 1, price: 11000.00),
          OrderItem(name: 'RGB Mousepad', quantity: 1, price: 3500.00),
        ],
        'amount': 14500.00,
        'status': 'Processing',
        'placedAt': '2026-07-24T14:45:00Z',
      },
      {
        'customer': 'Emma Watson',
        'itemsRaw': '4K Ultra HD Monitor 27"',
        'itemsList': [
          OrderItem(name: '4K Ultra HD Monitor 27"', quantity: 1, price: 42950.00),
        ],
        'amount': 42950.00,
        'status': 'Pending',
        'placedAt': '2026-07-24T16:00:00Z',
      },
      {
        'customer': 'David Kim',
        'itemsRaw': 'USB-C Docking Station, HDMI Cable',
        'itemsList': [
          OrderItem(name: 'USB-C Docking Station', quantity: 1, price: 8999.00),
          OrderItem(name: 'HDMI Cable (6ft)', quantity: 2, price: 1200.00),
        ],
        'amount': 11399.00,
        'status': 'Delivered',
        'placedAt': '2026-07-23T09:20:00Z',
      },
      {
        'customer': 'Liam Gallagher',
        'itemsRaw': 'Smart Home Speaker',
        'itemsList': [
          OrderItem(name: 'Smart Home Speaker', quantity: 1, price: 7999.00),
        ],
        'amount': 7999.00,
        'status': 'Cancelled',
        'placedAt': '2026-07-22T18:10:00Z',
      },
      {
        'customer': 'Olivia Taylor',
        'itemsRaw': 'Laptop Stand, Bluetooth Trackpad',
        'itemsList': [
          OrderItem(name: 'Laptop Stand', quantity: 1, price: 4500.00),
          OrderItem(name: 'Bluetooth Trackpad', quantity: 1, price: 6500.00),
        ],
        'amount': 11000.00,
        'status': 'Shipped',
        'placedAt': '2026-07-24T08:05:00Z',
      },
      {
        'customer': 'Ethan Brown',
        'itemsRaw': 'Noise Cancelling Earbuds',
        'itemsList': [
          OrderItem(name: 'Noise Cancelling Earbuds', quantity: 1, price: 12999.00),
        ],
        'amount': 12999.00,
        'status': 'Processing',
        'placedAt': '2026-07-24T17:30:00Z',
      },
    ];

    return List.generate(rawSeedData.length, (index) {
      final orderId = "ORD-${1000 + index + 1}";
      final d = rawSeedData[index];
      return Order(
        id: orderId,
        customer: d['customer'] as String,
        itemsRaw: d['itemsRaw'] as String,
        itemsList: d['itemsList'] as List<OrderItem>,
        amount: d['amount'] as double,
        status: d['status'] as String,
        placedAt: d['placedAt'] as String,
      );
    });
  }
}