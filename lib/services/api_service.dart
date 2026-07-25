import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  static const String _cacheKey = 'cached_orders_list';
  String baseUrl;
  bool simulateError = false;

  ApiService({this.baseUrl = 'https://6a635583b30b52361e1a2495.mockapi.io'});

  Dio get _dio => Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 6),
          receiveTimeout: const Duration(seconds: 6),
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
      final response = await _dio.get('/orders');

      List data = [];
      if (response.data is List) {
        data = response.data;
      } else if (response.data is Map && response.data.containsKey('orders')) {
        data = response.data['orders'];
      }

      final orders = data.map((e) => Order.fromJson(e)).toList();

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
      await prefs.setString(_cacheKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  Future<List<Order>> _getCachedOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw != null && raw.isNotEmpty) {
        final List decoded = jsonDecode(raw);
        return decoded.map((e) => Order.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  // Seed sample 8 orders for demo / fallback
  static List<Order> getSeedOrders() {
    return [
      Order(
        id: '101',
        customer: 'Alex Rivera',
        itemsRaw: 'Wireless Headphones, Protective Case',
        itemsList: [
          OrderItem(name: 'Wireless Headphones', quantity: 1, price: 149.99),
          OrderItem(name: 'Protective Case', quantity: 1, price: 19.99),
        ],
        amount: 169.98,
        status: 'Delivered',
        placedAt: '2026-07-24T10:30:00Z',
      ),
      Order(
        id: '102',
        customer: 'Sophia Chen',
        itemsRaw: 'Ergonomic Office Chair',
        itemsList: [
          OrderItem(name: 'Ergonomic Office Chair', quantity: 1, price: 299.00),
        ],
        amount: 299.00,
        status: 'Shipped',
        placedAt: '2026-07-24T12:15:00Z',
      ),
      Order(
        id: '103',
        customer: 'Marcus Johnson',
        itemsRaw: 'Mechanical Keyboard, RGB Mousepad',
        itemsList: [
          OrderItem(name: 'Mechanical Keyboard', quantity: 1, price: 110.00),
          OrderItem(name: 'RGB Mousepad', quantity: 1, price: 35.00),
        ],
        amount: 145.00,
        status: 'Processing',
        placedAt: '2026-07-24T14:45:00Z',
      ),
      Order(
        id: '104',
        customer: 'Emma Watson',
        itemsRaw: '4K Ultra HD Monitor 27"',
        itemsList: [
          OrderItem(name: '4K Ultra HD Monitor 27"', quantity: 1, price: 429.50),
        ],
        amount: 429.50,
        status: 'Pending',
        placedAt: '2026-07-24T16:00:00Z',
      ),
      Order(
        id: '105',
        customer: 'David Kim',
        itemsRaw: 'USB-C Docking Station, HDMI Cable',
        itemsList: [
          OrderItem(name: 'USB-C Docking Station', quantity: 1, price: 89.99),
          OrderItem(name: 'HDMI Cable (6ft)', quantity: 2, price: 12.00),
        ],
        amount: 113.99,
        status: 'Delivered',
        placedAt: '2026-07-23T09:20:00Z',
      ),
      Order(
        id: '106',
        customer: 'Liam Gallagher',
        itemsRaw: 'Smart Home Speaker',
        itemsList: [
          OrderItem(name: 'Smart Home Speaker', quantity: 1, price: 79.99),
        ],
        amount: 79.99,
        status: 'Cancelled',
        placedAt: '2026-07-22T18:10:00Z',
      ),
      Order(
        id: '107',
        customer: 'Olivia Taylor',
        itemsRaw: 'Laptop Stand, Bluetooth Trackpad',
        itemsList: [
          OrderItem(name: 'Laptop Stand', quantity: 1, price: 45.00),
          OrderItem(name: 'Bluetooth Trackpad', quantity: 1, price: 65.00),
        ],
        amount: 110.00,
        status: 'Shipped',
        placedAt: '2026-07-24T08:05:00Z',
      ),
      Order(
        id: '108',
        customer: 'Ethan Brown',
        itemsRaw: 'Noise Cancelling Earbuds',
        itemsList: [
          OrderItem(name: 'Noise Cancelling Earbuds', quantity: 1, price: 129.99),
        ],
        amount: 129.99,
        status: 'Processing',
        placedAt: '2026-07-24T17:30:00Z',
      ),
    ];
  }
}