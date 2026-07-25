import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ordertracker/providers/order_provider.dart';

void main() {
  group('OrderNotifier Provider Tests', () {
    test('Initial state loading and seed orders fallback', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(orderNotifierProvider.notifier);

      // Load mock seed data
      notifier.loadSeedOrders();

      final state = container.read(orderNotifierProvider);

      expect(state.allOrders.isNotEmpty, isTrue);
      expect(state.filteredOrders.length, equals(state.allOrders.length));
      expect(state.isLoading, isFalse);
    });

    test('Filtering by status updates filteredOrders correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(orderNotifierProvider.notifier);
      notifier.loadSeedOrders();

      notifier.setStatusFilter('Shipped');
      final state = container.read(orderNotifierProvider);

      expect(state.selectedStatusFilter, equals('Shipped'));
      for (final order in state.filteredOrders) {
        expect(order.normalizedStatus, equals('Shipped'));
      }
    });

    test('Search query filters orders by customer or ID', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(orderNotifierProvider.notifier);
      notifier.loadSeedOrders();

      notifier.setSearchQuery('Rivera');
      final state = container.read(orderNotifierProvider);

      expect(state.searchQuery, equals('Rivera'));
      expect(state.filteredOrders.length, equals(1));
      expect(state.filteredOrders.first.customer, contains('Rivera'));
    });

    test('Toggling simulated error updates state flag', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(orderNotifierProvider.notifier);
      expect(container.read(orderNotifierProvider).isSimulatedError, isFalse);

      notifier.toggleSimulatedError();
      expect(container.read(orderNotifierProvider).isSimulatedError, isTrue);
    });
  });
}
