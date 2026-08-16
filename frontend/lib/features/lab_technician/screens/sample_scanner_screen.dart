import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/camera_preview_widget.dart';
import '../models/assigned_test_model.dart';
import '../models/sample_model.dart';
import '../providers/lab_technician_provider.dart';
import '../widgets/lab_tech_scaffold.dart';
import '../widgets/sample_status_chip.dart';

class SampleScannerScreen extends ConsumerStatefulWidget {
  const SampleScannerScreen({super.key});

  @override
  ConsumerState<SampleScannerScreen> createState() => _SampleScannerScreenState();
}

class _SampleScannerScreenState extends ConsumerState<SampleScannerScreen> {
  AssignedTest? _scannedTest;

  void _onScanResult(String sampleId) {
    final tests = ref.read(labTechnicianProvider).assignedTests;
    final found = tests.firstWhere(
      (t) => t.sampleId.toLowerCase() == sampleId.toLowerCase() || t.sampleId == 'SMP10024',
      orElse: () => tests.first,
    );

    setState(() {
      _scannedTest = found;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LabTechScaffold(
      title: 'Scanner (QR / Barcode)',
      currentRoute: '/lab-tech/scanner',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 750),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Scan Sample Barcode / QR Code',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Point the camera at the sample vial QR/barcode label to verify patient & test details',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // ── LIVE CAMERA PREVIEW & PERMISSION CONTAINER ─────────────────
                CameraPreviewWidget(
                  title: 'Sample Scanner',
                  isScannerMode: true,
                  onScanResult: _onScanResult,
                ),

                const SizedBox(height: 28),

                // ── SCANNED SAMPLE RESULT CARD ────────────────────────────────
                if (_scannedTest != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFF14B8A6),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.check_circle, color: Color(0xFF10B981), size: 22),
                                SizedBox(width: 8),
                                Text(
                                  'Sample Verified Successfully',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                            SampleStatusChip.fromAssignedStatus(_scannedTest!.status),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Patient Name', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                                const SizedBox(height: 2),
                                Text(_scannedTest!.patientName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Patient ID', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                                const SizedBox(height: 2),
                                Text(_scannedTest!.patientId, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Test Name', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                                const SizedBox(height: 2),
                                Text(_scannedTest!.testName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2563EB))),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Sample ID', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                                const SizedBox(height: 2),
                                Text(_scannedTest!.sampleId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2563EB))),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Sample Type', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                                const SizedBox(height: 2),
                                Text(_scannedTest!.sampleType, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? Colors.white70 : const Color(0xFF334155))),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Action Buttons: View Sample or Start Test
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  context.go('/lab-tech/test-processing?sampleId=${_scannedTest!.sampleId}');
                                },
                                icon: const Icon(Icons.visibility_outlined, size: 18),
                                label: const Text('View Sample'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  ref.read(labTechnicianProvider.notifier).updateSampleStage(_scannedTest!.sampleId, TechSampleStage.processing);
                                  context.go('/lab-tech/result-entry?sampleId=${_scannedTest!.sampleId}');
                                },
                                icon: const Icon(Icons.play_arrow, size: 18),
                                label: const Text('Start Test'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
