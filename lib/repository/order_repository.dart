import '../models/order.dart';
import '../services/api_service.dart';

class OrderRepository {
  final ApiService apiService;

  OrderRepository(this.apiService);

  Future<FetchOrdersResponse> getOrdersResponse() async {
    return await apiService.fetchOrdersResponse();
  }

  Future<List<Order>> getOrders() async {
    return await apiService.fetchOrders();
  }
}