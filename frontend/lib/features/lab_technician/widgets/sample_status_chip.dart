import 'package:flutter/material.dart';
import '../models/assigned_test_model.dart';
import '../models/test_result_model.dart';

class SampleStatusChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const SampleStatusChip({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });

  factory SampleStatusChip.fromAssignedStatus(AssignedTestStatus status) {
    switch (status) {
      case AssignedTestStatus.pending:
        return const SampleStatusChip(
          label: 'Pending',
          backgroundColor: Color(0xFFFEF3C7),
          textColor: Color(0xFFD97706),
          icon: Icons.hourglass_empty,
        );
      case AssignedTestStatus.sampleCollected:
        return const SampleStatusChip(
          label: 'Sample Collected',
          backgroundColor: Color(0xFFEFF6FF),
          textColor: Color(0xFF2563EB),
          icon: Icons.bloodtype,
        );
      case AssignedTestStatus.inProgress:
        return const SampleStatusChip(
          label: 'In Progress',
          backgroundColor: Color(0xFFE0F2FE),
          textColor: Color(0xFF0284C7),
          icon: Icons.biotech,
        );
      case AssignedTestStatus.resultEntered:
        return const SampleStatusChip(
          label: 'Result Entered',
          backgroundColor: Color(0xFFF3E8FF),
          textColor: Color(0xFF7C3AED),
          icon: Icons.edit_note,
        );
      case AssignedTestStatus.completed:
        return const SampleStatusChip(
          label: 'Completed',
          backgroundColor: Color(0xFFD1FAE5),
          textColor: Color(0xFF059669),
          icon: Icons.check_circle,
        );
    }
  }

  factory SampleStatusChip.fromPriority(TestPriority priority) {
    switch (priority) {
      case TestPriority.high:
        return const SampleStatusChip(
          label: 'High',
          backgroundColor: Color(0xFFFEE2E2),
          textColor: Color(0xFFDC2626),
          icon: Icons.priority_high,
        );
      case TestPriority.normal:
        return const SampleStatusChip(
          label: 'Normal',
          backgroundColor: Color(0xFFECFDF5),
          textColor: Color(0xFF10B981),
        );
      case TestPriority.low:
        return const SampleStatusChip(
          label: 'Low',
          backgroundColor: Color(0xFFF3F4F6),
          textColor: Color(0xFF6B7280),
        );
    }
  }

  factory SampleStatusChip.fromResultFlag(ResultStatusFlag flag) {
    switch (flag) {
      case ResultStatusFlag.normal:
        return const SampleStatusChip(
          label: 'Normal',
          backgroundColor: Color(0xFFD1FAE5),
          textColor: Color(0xFF059669),
        );
      case ResultStatusFlag.high:
        return const SampleStatusChip(
          label: 'High',
          backgroundColor: Color(0xFFFEE2E2),
          textColor: Color(0xFFDC2626),
        );
      case ResultStatusFlag.low:
        return const SampleStatusChip(
          label: 'Low',
          backgroundColor: Color(0xFFFEF3C7),
          textColor: Color(0xFFD97706),
        );
      case ResultStatusFlag.critical:
        return const SampleStatusChip(
          label: 'Critical',
          backgroundColor: Color(0xFF991B1B),
          textColor: Colors.white,
          icon: Icons.warning,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
