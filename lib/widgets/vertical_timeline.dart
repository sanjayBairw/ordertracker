import 'package:flutter/material.dart';

class TimelineStepData {
  final String title;
  final String description;
  final String statusKey;
  final IconData icon;

  TimelineStepData({
    required this.title,
    required this.description,
    required this.statusKey,
    required this.icon,
  });
}

class VerticalTimeline extends StatefulWidget {
  final String currentStatus;

  const VerticalTimeline({super.key, required this.currentStatus});

  @override
  State<VerticalTimeline> createState() => _VerticalTimelineState();
}

class _VerticalTimelineState extends State<VerticalTimeline> with TickerProviderStateMixin {
  late AnimationController _timelineController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  final List<TimelineStepData> _steps = [
    TimelineStepData(
      title: 'Order Placed',
      description: 'Your order was successfully placed.',
      statusKey: 'Pending',
      icon: Icons.assignment_turned_in_rounded,
    ),
    TimelineStepData(
      title: 'Processing',
      description: 'Order is being packed and prepared.',
      statusKey: 'Processing',
      icon: Icons.inventory_2_rounded,
    ),
    TimelineStepData(
      title: 'Shipped',
      description: 'Package is in transit with courier.',
      statusKey: 'Shipped',
      icon: Icons.local_shipping_rounded,
    ),
    TimelineStepData(
      title: 'Delivered',
      description: 'Package delivered to recipient.',
      statusKey: 'Delivered',
      icon: Icons.check_circle_rounded,
    ),
  ];

  int _getStepIndex(String status) {
    final lower = status.trim().toLowerCase();
    if (lower.contains('cancel')) return -1;
    if (lower.contains('pend')) return 0;
    if (lower.contains('process')) return 1;
    if (lower.contains('ship')) return 2;
    if (lower.contains('deliver')) return 3;
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _timelineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _progressAnimation = CurvedAnimation(
      parent: _timelineController,
      curve: Curves.easeInOutCubic,
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _timelineController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _timelineController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = _getStepIndex(widget.currentStatus);
    final isCancelled = widget.currentStatus.trim().toLowerCase().contains('cancel');

    if (isCancelled) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Row(
          children: const [
            Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 36),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Cancelled',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF991B1B),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'This order was cancelled and will not be processed further.',
                    style: TextStyle(fontSize: 13, color: Color(0xFFB91C1C)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final totalSegments = _steps.length - 1;
    final targetProgressRatio = activeIndex <= 0
        ? 0.0
        : (activeIndex / totalSegments).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: Listenable.merge([_progressAnimation, _pulseAnimation]),
      builder: (context, child) {
        final currentProgress = _progressAnimation.value * targetProgressRatio;

        return Column(
          children: List.generate(_steps.length, (index) {
            final isCompleted = index <= activeIndex;
            final isCurrent = index == activeIndex;
            final isLast = index == _steps.length - 1;

            final segmentStart = index / totalSegments;
            final segmentEnd = (index + 1) / totalSegments;
            final segmentProgress = targetProgressRatio == 0
                ? 0.0
                : ((currentProgress - segmentStart) / (segmentEnd - segmentStart)).clamp(0.0, 1.0);

            final nodeReveal = targetProgressRatio == 0
                ? (index == 0 ? 1.0 : 0.0)
                : ((currentProgress - (segmentStart - 0.15)) / 0.25).clamp(0.0, 1.0);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 40,
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isCurrent ? 34 : 26,
                        height: isCurrent ? 34 : 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? (isCurrent ? const Color(0xFF4F46E5) : const Color(0xFF10B981))
                              : const Color(0xFFE5E7EB),
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF4F46E5).withValues(
                                      alpha: 0.25 + (_pulseAnimation.value * 0.25),
                                    ),
                                    blurRadius: 8 + (_pulseAnimation.value * 8),
                                    spreadRadius: 2 + (_pulseAnimation.value * 3),
                                  )
                                ]
                              : null,
                        ),
                        child: Icon(
                          isCompleted ? (isCurrent ? _steps[index].icon : Icons.check_rounded) : Icons.circle,
                          size: isCurrent ? 18 : 14,
                          color: isCompleted ? Colors.white : const Color(0xFF9CA3AF),
                        ),
                      ),
                      if (!isLast)
                        SizedBox(
                          height: 42,
                          width: 3,
                          child: Stack(
                            children: [
                              Container(color: const Color(0xFFE5E7EB)),
                              Align(
                                alignment: Alignment.topCenter,
                                child: FractionallySizedBox(
                                  heightFactor: segmentProgress,
                                  child: Container(color: const Color(0xFF10B981)),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Transform.translate(
                      offset: Offset((1.0 - nodeReveal) * 10, 0),
                      child: Opacity(
                        opacity: isCompleted ? (0.4 + (nodeReveal * 0.6)).clamp(0.0, 1.0) : 0.4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _steps[index].title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isCurrent
                                    ? FontWeight.bold
                                    : (isCompleted ? FontWeight.w600 : FontWeight.w500),
                                color: isCompleted ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _steps[index].description,
                              style: TextStyle(
                                fontSize: 13,
                                color: isCompleted ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }
}
