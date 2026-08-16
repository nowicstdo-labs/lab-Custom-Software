import 'package:flutter/material.dart';
import '../models/sample_model.dart';

class TestStatusTimeline extends StatelessWidget {
  final TechSampleStage currentStage;
  final ValueChanged<TechSampleStage>? onStageTap;

  const TestStatusTimeline({
    super.key,
    required this.currentStage,
    this.onStageTap,
  });

  static const List<TechSampleStage> stages = [
    TechSampleStage.sampleCollected,
    TechSampleStage.sampleReceived,
    TechSampleStage.processing,
    TechSampleStage.testing,
    TechSampleStage.resultEntered,
    TechSampleStage.completed,
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = currentStage.stepIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Test Workflow Progress',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(stages.length, (index) {
                      final stage = stages[index];
                      final isDone = index < currentIndex;
                      final isCurrent = index == currentIndex;

                      Color circleBg;
                      Color iconColor;
                      if (isDone) {
                        circleBg = const Color(0xFF10B981);
                        iconColor = Colors.white;
                      } else if (isCurrent) {
                        circleBg = const Color(0xFF2563EB);
                        iconColor = Colors.white;
                      } else {
                        circleBg = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
                        iconColor = isDark ? const Color(0xFF64748B) : Colors.white;
                      }

                      return InkWell(
                        onTap: onStageTap != null ? () => onStageTap!(stage) : null,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedScale(
                                scale: isCurrent ? 1.15 : 1.0,
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOutCubic,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: circleBg,
                                    shape: BoxShape.circle,
                                    boxShadow: isCurrent
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Icon(
                                    isDone ? Icons.check : (isCurrent ? Icons.play_arrow : Icons.circle_outlined),
                                    size: 16,
                                    color: iconColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 250),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                                  color: isCurrent
                                      ? const Color(0xFF2563EB)
                                      : (isDone
                                          ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
                                          : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8))),
                                ),
                                child: Text(
                                  stage.displayName,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
