import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/order_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/footer_credit.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _apiUrlController;

  @override
  void initState() {
    super.initState();
    final currentUrl = ref.read(orderNotifierProvider).customApiUrl;
    _apiUrlController = TextEditingController(text: currentUrl);
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final orderState = ref.watch(orderNotifierProvider);
    final orderNotifier = ref.read(orderNotifierProvider.notifier);
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Mode Section Header
            Text(
              'Appearance',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 10),

            // Theme Mode Card
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
              ),
              child: Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: const Text('System Default'),
                    secondary: const Icon(Icons.settings_system_daydream_rounded),
                    value: ThemeMode.system,
                    groupValue: themeMode,
                    activeColor: const Color(0xFF4F46E5),
                    onChanged: (val) {
                      if (val != null) themeNotifier.setThemeMode(val);
                    },
                  ),
                  const Divider(height: 1),
                  RadioListTile<ThemeMode>(
                    title: const Text('Light Mode'),
                    secondary: const Icon(Icons.light_mode_rounded),
                    value: ThemeMode.light,
                    groupValue: themeMode,
                    activeColor: const Color(0xFF4F46E5),
                    onChanged: (val) {
                      if (val != null) themeNotifier.setThemeMode(val);
                    },
                  ),
                  const Divider(height: 1),
                  RadioListTile<ThemeMode>(
                    title: const Text('Dark Mode'),
                    secondary: const Icon(Icons.dark_mode_rounded),
                    value: ThemeMode.dark,
                    groupValue: themeMode,
                    activeColor: const Color(0xFF4F46E5),
                    onChanged: (val) {
                      if (val != null) themeNotifier.setThemeMode(val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // API Configuration Section Header
            Text(
              'Mock API Endpoint',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 10),

            // API Configuration Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _apiUrlController,
                    decoration: InputDecoration(
                      labelText: 'Mock API Base URL',
                      hintText: 'https://6a635583b30b52361e1a2495.mockapi.io',
                      prefixIcon: const Icon(Icons.link_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        orderState.isOffline ? 'Status: Offline (Cached)' : 'Status: Online',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: orderState.isOffline ? Colors.amber.shade700 : Colors.green,
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          final url = _apiUrlController.text.trim();
                          if (url.isNotEmpty) {
                            orderNotifier.updateApiUrl(url);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('API Base URL updated successfully!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.save_rounded, size: 16),
                        label: const Text('Save & Fetch'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // About App Section Header
            Text(
              'About Application',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 10),

            // About Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.info_outline_rounded, color: Color(0xFF4F46E5)),
                    ),
                    title: const Text('Order Tracker App', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Version 1.0.0 • Production Build'),
                  ),
                  const Divider(),
                  const ListTile(
                    leading: Icon(Icons.flutter_dash_rounded, color: Colors.blue),
                    title: Text('Built with Flutter & Riverpod'),
                    subtitle: Text('Material 3 • Dio REST API • Local Caching'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const FooterCredit(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
