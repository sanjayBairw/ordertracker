import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../repository/order_repository.dart';
import '../services/api_service.dart';

class OrderState {
  final List<Order> allOrders;
  final List<Order> filteredOrders;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final String selectedStatusFilter;
  final bool isSimulatedError;
  final String customApiUrl;
  final bool isOffline;
  final bool justReconnected;
  final DateTime? lastSyncTime;

  const OrderState({
    this.allOrders = const [],
    this.filteredOrders = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.selectedStatusFilter = 'All',
    this.isSimulatedError = false,
    this.customApiUrl = 'https://6a635583b30b52361e1a2495.mockapi.io',
    this.isOffline = false,
    this.justReconnected = false,
    this.lastSyncTime,
  });

  OrderState copyWith({
    List<Order>? allOrders,
    List<Order>? filteredOrders,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? searchQuery,
    String? selectedStatusFilter,
    bool? isSimulatedError,
    String? customApiUrl,
    bool? isOffline,
    bool? justReconnected,
    DateTime? lastSyncTime,
  }) {
    return OrderState(
      allOrders: allOrders ?? this.allOrders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatusFilter: selectedStatusFilter ?? this.selectedStatusFilter,
      isSimulatedError: isSimulatedError ?? this.isSimulatedError,
      customApiUrl: customApiUrl ?? this.customApiUrl,
      isOffline: isOffline ?? this.isOffline,
      justReconnected: justReconnected ?? this.justReconnected,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}

class OrderNotifier extends Notifier<OrderState> {
  late ApiService _apiService;
  late OrderRepository _repository;

  @override
  OrderState build() {
    const initialState = OrderState();
    _apiService = ApiService(baseUrl: initialState.customApiUrl);
    _repository = OrderRepository(_apiService);

    Future.microtask(() => loadOrders());

    return initialState;
  }

  void updateApiUrl(String newUrl) {
    state = state.copyWith(customApiUrl: newUrl);
    _apiService.baseUrl = newUrl;
    loadOrders();
  }

  void toggleSimulatedError() {
    final nextState = !state.isSimulatedError;
    state = state.copyWith(isSimulatedError: nextState);
    _apiService.simulateError = nextState;
    loadOrders();
  }

  Future<void> loadOrders() async {
    final wasOffline = state.isOffline;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final res = await _repository.getOrdersResponse();
      final reconnected = wasOffline && !res.isOffline;

      _applyFilterAndSort(
        res.orders,
        state.searchQuery,
        state.selectedStatusFilter,
        res.isOffline,
        reconnected: reconnected,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isOffline: true,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void acknowledgeReconnection() {
    if (state.justReconnected) {
      state = state.copyWith(justReconnected: false);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilterAndSort(state.allOrders, query, state.selectedStatusFilter, state.isOffline);
  }

  void setStatusFilter(String status) {
    state = state.copyWith(selectedStatusFilter: status);
    _applyFilterAndSort(state.allOrders, state.searchQuery, status, state.isOffline);
  }

  void _applyFilterAndSort(
    List<Order> orders,
    String query,
    String statusFilter,
    bool offline, {
    bool reconnected = false,
  }) {
    List<Order> result = List.from(orders);

    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      result = result.where((o) {
        return o.id.toLowerCase().contains(q) ||
            o.customer.toLowerCase().contains(q) ||
            o.itemsRaw.toLowerCase().contains(q) ||
            o.status.toLowerCase().contains(q);
      }).toList();
    }

    if (statusFilter != 'All') {
      result = result.where((o) => o.normalizedStatus.toLowerCase() == statusFilter.toLowerCase()).toList();
    }

    state = state.copyWith(
      allOrders: orders,
      filteredOrders: result,
      isLoading: false,
      clearError: true,
      isOffline: offline,
      justReconnected: reconnected,
      lastSyncTime: offline ? state.lastSyncTime : DateTime.now(),
    );
  }

  void loadSeedOrders() {
    final seed = ApiService.getSeedOrders();
    _applyFilterAndSort(seed, state.searchQuery, state.selectedStatusFilter, false);
  }
}

final orderNotifierProvider = NotifierProvider<OrderNotifier, OrderState>(OrderNotifier.new);