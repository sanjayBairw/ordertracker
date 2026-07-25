import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 14, color: config.textColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              config.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: config.textColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(String rawStatus) {
    final lower = rawStatus.trim().toLowerCase();

    if (lower.contains('pend')) {
      return _StatusConfig(
        label: 'Pending',
        backgroundColor: const Color(0xFFFFF7ED),
        borderColor: const Color(0xFFFFEDD5),
        textColor: const Color(0xFFC2410C),
        icon: Icons.schedule_rounded,
      );
    } else if (lower.contains('process')) {
      return _StatusConfig(
        label: 'Processing',
        backgroundColor: const Color(0xFFEFF6FF),
        borderColor: const Color(0xFFDBEAFE),
        textColor: const Color(0xFF1D4ED8),
        icon: Icons.sync_rounded,
      );
    } else if (lower.contains('ship')) {
      return _StatusConfig(
        label: 'Shipped',
        backgroundColor: const Color(0xFFF5F3FF),
        borderColor: const Color(0xFFDDD6FE),
        textColor: const Color(0xFF6D28D9),
        icon: Icons.local_shipping_rounded,
      );
    } else if (lower.contains('deliver')) {
      return _StatusConfig(
        label: 'Delivered',
        backgroundColor: const Color(0xFFECFDF5),
        borderColor: const Color(0xFFA7F3D0),
        textColor: const Color(0xFF047857),
        icon: Icons.check_circle_rounded,
      );
    } else if (lower.contains('cancel')) {
      return _StatusConfig(
        label: 'Cancelled',
        backgroundColor: const Color(0xFFFEF2F2),
        borderColor: const Color(0xFFFECACA),
        textColor: const Color(0xFFB91C1C),
        icon: Icons.cancel_rounded,
      );
    }

    return _StatusConfig(
      label: rawStatus.isEmpty ? 'Pending' : rawStatus,
      backgroundColor: const Color(0xFFF3F4F6),
      borderColor: const Color(0xFFE5E7EB),
      textColor: const Color(0xFF374151),
      icon: Icons.info_outline_rounded,
    );
  }
}

class _StatusConfig {
  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final IconData icon;

  _StatusConfig({
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.icon,
  });
}
