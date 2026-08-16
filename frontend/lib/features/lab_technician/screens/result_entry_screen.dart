import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/test_result_model.dart';
import '../providers/lab_technician_provider.dart';
import '../widgets/lab_tech_scaffold.dart';
import '../widgets/result_input_field.dart';

class ResultEntryScreen extends ConsumerStatefulWidget {
  final String? sampleId;

  const ResultEntryScreen({super.key, this.sampleId});

  @override
  ConsumerState<ResultEntryScreen> createState() => _ResultEntryScreenState();
}

class _ResultEntryScreenState extends ConsumerState<ResultEntryScreen> {
  late String _currentSampleId;
  late List<DynamicTestParameter> _parameters;
  late TextEditingController _remarksController;
  late DynamicTestResultRecord _activeRecord;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _currentSampleId = widget.sampleId ?? 'SMP10024';
    _remarksController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _loadRecordData();
      _isInitialized = true;
    }
  }

  void _loadRecordData() {
    final techState = ref.read(labTechnicianProvider);
    final existing = techState.results.firstWhere(
      (r) => r.sampleId == _currentSampleId,
      orElse: () {
        final test = techState.assignedTests.firstWhere(
          (t) => t.sampleId == _currentSampleId,
          orElse: () => techState.assignedTests.first,
        );
        final templateParams = ref.read(labTechnicianProvider.notifier).getTemplateForTest(test.testName);
        return DynamicTestResultRecord(
          resultId: 'R-${test.sampleId}',
          sampleId: test.sampleId,
          patientId: test.patientId,
          patientName: test.patientName,
          patientAgeGender: test.patientAgeGender,
          testName: test.testName,
          sampleType: test.sampleType,
          parameters: templateParams,
          remarks: 'All parameters are within normal range.',
          technicianName: techState.profile.name,
          testDate: test.appointmentDate,
        );
      },
    );

    _activeRecord = existing;
    _parameters = List<DynamicTestParameter>.from(existing.parameters);
    _remarksController.text = existing.remarks;
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  void _onParameterChanged(int index, DynamicTestParameter updated) {
    setState(() {
      _parameters[index] = updated;
      _activeRecord = _activeRecord.copyWith(parameters: _parameters);
    });
  }

  void _handleSaveDraft() {
    final updatedRecord = _activeRecord.copyWith(
      parameters: _parameters,
      remarks: _remarksController.text,
    );
    ref.read(labTechnicianProvider.notifier).saveTestResultDraft(updatedRecord);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test result saved as draft successfully!'),
        backgroundColor: Color(0xFF2563EB),
      ),
    );
  }

  void _handleMarkCompleted() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF10B981)),
            SizedBox(width: 8),
            Text('Complete Test Submission'),
          ],
        ),
        content: const Text(
          'Are you sure you want to mark this test as Completed? Once submitted, the results will be locked for report generation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final finalRecord = _activeRecord.copyWith(
                parameters: _parameters,
                remarks: _remarksController.text,
                isDraft: false,
                isCompleted: true,
              );
              ref.read(labTechnicianProvider.notifier).markTestCompleted(finalRecord);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Test marked as Completed and submitted!'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );

              context.go('/lab-tech/report-preview?sampleId=${_activeRecord.sampleId}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm & Complete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LabTechScaffold(
      title: 'Result Entry',
      currentRoute: '/lab-tech/result-entry',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── TOP HEADER CARD WITH TEST & SAMPLE INFO ──────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test:',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _activeRecord.testName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Patient: ${_activeRecord.patientName} (${_activeRecord.patientId})',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Sample ID:',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _activeRecord.sampleId,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _activeRecord.isCompleted
                              ? const Color(0xFFD1FAE5)
                              : const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _activeRecord.isCompleted ? 'Completed' : 'Result Entry',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _activeRecord.isCompleted
                                ? const Color(0xFF059669)
                                : const Color(0xFF7C3AED),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── RESULT ENTRY PARAMETERS TABLE HEADER ────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Parameter',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Result Value',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: Text(
                      'Unit',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 80, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                ],
              ),
            ),

            // PARAMETER INPUT ROWS
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _parameters.length,
              itemBuilder: (context, index) {
                return ResultInputField(
                  parameter: _parameters[index],
                  onChanged: (updatedParam) => _onParameterChanged(index, updatedParam),
                );
              },
            ),

            const SizedBox(height: 24),

            // ── REMARKS MULTILINE INPUT ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Remarks (Optional)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _remarksController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Enter remarks here...',
                      filled: true,
                      fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── BOTTOM ACTION BUTTONS ([ Save Draft ] and [ Mark Test Completed ])
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _handleSaveDraft,
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: const Text('Save Draft'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                      foregroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _handleMarkCompleted,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Mark Test Completed'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
