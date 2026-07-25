class ApiConstants {
  static const String defaultBaseUrl = 'https://6a635583b30b52361e1a2495.mockapi.io';
  static const String ordersEndpoint = '/orders';
  static const Duration connectTimeout = Duration(seconds: 6);
  static const Duration receiveTimeout = Duration(seconds: 6);
  static const String cacheKey = 'cached_orders_list';
}
