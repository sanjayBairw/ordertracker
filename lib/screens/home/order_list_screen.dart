import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/order_provider.dart';
import '../../widgets/footer_credit.dart';
import '../../widgets/order_card.dart';
import '../order_detail_screen.dart';
import '../settings_screen.dart';

class OrderListScreen extends ConsumerStatefulWidget {
  const OrderListScreen({super.key});

  @override
  ConsumerState<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends ConsumerState<OrderListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  final List<String> _statusFilters = [
    'All',
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query, OrderNotifier notifier) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      notifier.setSearchQuery(query);
    });
  }

  String _formatTime(DateTime time) {
    final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderNotifierProvider);
    final notifier = ref.read(orderNotifierProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Reconnection Listener
    ref.listen<OrderState>(orderNotifierProvider, (previous, next) {
      if (next.justReconnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF059669),
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
            content: Row(
              children: const [
                Icon(Icons.wifi_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Back Online! Synced latest live orders.',
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        );
        ref.read(orderNotifierProvider.notifier).acknowledgeReconnection();
      }
    });

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Tracker',
              style: TextStyle(
                color: isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827),
                fontWeight: FontWeight.w800,
                fontSize: 22,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Live Status & Real-time Delivery',
              style: TextStyle(
                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              orderState.isSimulatedError
                  ? Icons.wifi_off_rounded
                  : Icons.wifi_rounded,
              color: orderState.isSimulatedError ? Colors.red : const Color(0xFF10B981),
            ),
            tooltip: orderState.isSimulatedError
                ? 'Simulated Offline Mode Active (Tap to Reconnect)'
                : 'Connection Status: Online (Tap to Simulate Offline)',
            onPressed: () {
              notifier.toggleSimulatedError();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    orderState.isSimulatedError
                        ? 'Reconnecting to network...'
                        : 'Simulating Offline Mode (Testing Offline Cache & Reconnection)',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF6366F1)),
            tooltip: 'App Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: RefreshIndicator(
            onRefresh: () async {
              await notifier.loadOrders();
            },
            color: const Color(0xFF4F46E5),
            child: Column(
              children: [
                // Offline Notification Banner
                if (orderState.isOffline && orderState.allOrders.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF78350F).withValues(alpha: 0.4) : const Color(0xFFFFFBEB),
                      border: Border(bottom: BorderSide(color: isDark ? const Color(0xFFB45309) : const Color(0xFFFDE68A), width: 1)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFEF3C7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.wifi_off_rounded, size: 14, color: Color(0xFFD97706)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Offline Mode — Displaying cached orders',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (orderState.lastSyncTime != null)
                                Text(
                                  'Last synced: ${_formatTime(orderState.lastSyncTime!)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? const Color(0xFFF59E0B) : const Color(0xFFB45309),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFF59E0B),
                            side: const BorderSide(color: Color(0xFFF59E0B)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => notifier.loadOrders(),
                          icon: const Icon(Icons.refresh_rounded, size: 12),
                          label: const Text('Retry', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),

                // Top Search & Filter Bar
                Container(
                  color: isDark ? const Color(0xFF1F2937) : Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Column(
                    children: [
                      // Search Field with 350ms Debounce
                      TextField(
                        controller: _searchController,
                        onChanged: (val) => _onSearchChanged(val, notifier),
                        decoration: InputDecoration(
                          hintText: 'Search by Order #, Customer, or Item...',
                          hintStyle: TextStyle(fontSize: 14, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF9CA3AF)),
                          prefixIcon: Icon(Icons.search_rounded, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    notifier.setSearchQuery('');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Horizontal Status Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: _statusFilters.map((filter) {
                            final isSelected = orderState.selectedStatusFilter == filter;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(filter),
                                selected: isSelected,
                                selectedColor: const Color(0xFF4F46E5),
                                backgroundColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : (isDark ? const Color(0xFFE5E7EB) : const Color(0xFF4B5563)),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  fontSize: 13,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                showCheckmark: false,
                                onSelected: (selected) {
                                  if (selected) notifier.setStatusFilter(filter);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Content Area
                Expanded(
                  child: _buildMainContent(context, orderState, notifier, isDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, OrderState state, OrderNotifier notifier, bool isDark) {
    // 1. Loading State (Shimmer Skeleton Cards)
    if (state.isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (context, index) => _buildSkeletonCard(isDark),
      );
    }

    // 2. Full-Screen Offline / Network Error State
    if (state.errorMessage != null && state.allOrders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF78350F).withValues(alpha: 0.3) : const Color(0xFFFFFBEB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.wifi_off_rounded, size: 54, color: Color(0xFFD97706)),
              ),
              const SizedBox(height: 20),
              Text(
                'Network Unavailable',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF111827)),
              ),
              const SizedBox(height: 10),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280), height: 1.4),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => notifier.loadOrders(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry Connection'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6366F1),
                      side: const BorderSide(color: Color(0xFF6366F1)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => notifier.loadSeedOrders(),
                    icon: const Icon(Icons.dataset_rounded),
                    label: const Text('Load Demo Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // 3. Empty Search / Filter State Widget
    if (state.filteredOrders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.search_off_rounded, size: 48, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF9CA3AF)),
              ),
              const SizedBox(height: 16),
              Text(
                'No Orders Found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF111827)),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search terms or status filter.',
                style: TextStyle(fontSize: 14, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  _searchController.clear();
                  notifier.setSearchQuery('');
                  notifier.setStatusFilter('All');
                },
                child: const Text('Reset Filters'),
              ),
            ],
          ),
        ),
      );
    }

    // 4. Success State — List with Staggered Entrance Animation
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      itemCount: state.filteredOrders.length + 1,
      itemBuilder: (context, index) {
        if (index == state.filteredOrders.length) {
          return const FooterCredit();
        }

        final order = state.filteredOrders[index];

        return TweenAnimationBuilder<double>(
          key: ValueKey('order_card_${order.id}_$index'),
          duration: Duration(milliseconds: 350 + (index * 65).clamp(0, 600)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, (1 - value) * 35),
              child: Transform.scale(
                scale: 0.93 + (0.07 * value),
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: OrderCard(
                    order: order,
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 450),
                          reverseTransitionDuration: const Duration(milliseconds: 350),
                          pageBuilder: (context, animation, secondaryAnimation) => OrderDetailScreen(order: order),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            final curvedAnimation = CurvedAnimation(
                              parent: animation,
                              curve: Curves.fastOutSlowIn,
                              reverseCurve: Curves.easeInCubic,
                            );
                            return FadeTransition(
                              opacity: CurvedAnimation(
                                parent: animation,
                                curve: const Interval(0.0, 0.85, curve: Curves.easeOut),
                              ),
                              child: ScaleTransition(
                                scale: Tween<double>(begin: 0.96, end: 1.0).animate(curvedAnimation),
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.06, 0.0),
                                    end: Offset.zero,
                                  ).animate(curvedAnimation),
                                  child: child,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSkeletonCard(bool isDark) {
    final baseColor = isDark ? const Color(0xFF374151) : Colors.grey.shade200;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: 110, height: 16, decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(6))),
              Container(width: 80, height: 22, decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(12))),
            ],
          ),
          const SizedBox(height: 14),
          Container(width: 140, height: 14, decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(6))),
          const SizedBox(height: 8),
          Container(width: 200, height: 14, decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(6))),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: 90, height: 18, decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(6))),
              Container(width: 70, height: 14, decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(6))),
            ],
          ),
        ],
      ),
    );
  }
}
