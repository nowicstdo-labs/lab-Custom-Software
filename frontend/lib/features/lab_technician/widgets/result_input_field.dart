import 'package:flutter/material.dart';
import '../models/test_result_model.dart';
import 'sample_status_chip.dart';

class ResultInputField extends StatelessWidget {
  final DynamicTestParameter parameter;
  final ValueChanged<DynamicTestParameter> onChanged;

  const ResultInputField({
    super.key,
    required this.parameter,
    required this.onChanged,
  });

  ResultStatusFlag _evaluateStatus(String val, double? minVal, double? maxVal) {
    final parsed = double.tryParse(val.trim());
    if (parsed == null) return ResultStatusFlag.normal;
    if (minVal != null && parsed < minVal) return ResultStatusFlag.low;
    if (maxVal != null && parsed > maxVal) return ResultStatusFlag.high;
    return ResultStatusFlag.normal;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            // Parameter Name
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parameter.parameterName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Range: ${parameter.referenceRange}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Result Value Input Field
            Expanded(
              flex: 2,
              child: TextFormField(
                initialValue: parameter.resultValue,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                  ),
                ),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                onChanged: (val) {
                  final calculatedFlag = _evaluateStatus(val, parameter.minVal, parameter.maxVal);
                  onChanged(parameter.copyWith(resultValue: val, status: calculatedFlag));
                },
              ),
            ),
            const SizedBox(width: 12),

            // Unit
            SizedBox(
              width: 70,
              child: Text(
                parameter.unit,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Status Chip (Normal / High / Low) with Smooth AnimatedSwitcher Transition
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
              child: KeyedSubtree(
                key: ValueKey(parameter.status),
                child: SampleStatusChip.fromResultFlag(parameter.status),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
