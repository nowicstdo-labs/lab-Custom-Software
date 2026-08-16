import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/assigned_test_model.dart';
import '../models/sample_model.dart';
import '../providers/lab_technician_provider.dart';
import '../widgets/lab_tech_scaffold.dart';
import '../widgets/sample_status_chip.dart';
import '../widgets/test_status_timeline.dart';

class TestProcessingScreen extends ConsumerWidget {
  final String? sampleId;

  const TestProcessingScreen({super.key, this.sampleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final techState = ref.watch(labTechnicianProvider);
    final techNotifier = ref.read(labTechnicianProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currentSampleId = sampleId ?? 'SMP10024';
    final targetTest = techState.assignedTests.firstWhere(
      (t) => t.sampleId == currentSampleId,
      orElse: () => techState.assignedTests.first,
    );

    final targetSample = techState.samples.firstWhere(
      (s) => s.sampleId == currentSampleId,
      orElse: () => techState.samples.first,
    );

    return LabTechScaffold(
      title: 'Test Processing',
      currentRoute: '/lab-tech/test-processing',
      actions: [
        SampleStatusChip.fromAssignedStatus(targetTest.status),
        const SizedBox(width: 16),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── TOP TWO INFO CARDS (PATIENT INFO & TEST INFO) ─────────────────
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 800;
                return isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _PatientInfoCard(test: targetTest, isDark: isDark)),
                          const SizedBox(width: 20),
                          Expanded(child: _TestInfoCard(test: targetTest, isDark: isDark)),
                        ],
                      )
                    : Column(
                        children: [
                          _PatientInfoCard(test: targetTest, isDark: isDark),
                          const SizedBox(height: 16),
                          _TestInfoCard(test: targetTest, isDark: isDark),
                        ],
                      );
              },
            ),

            const SizedBox(height: 24),

            // ── SAMPLE INFORMATION & WORKFLOW TIMELINE CARD ──────────────────
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.water_drop, color: Color(0xFF2563EB), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Sample Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 28,
                    runSpacing: 12,
                    children: [
                      _DetailItem(label: 'Sample ID', value: targetTest.sampleId, isHighlight: true),
                      _DetailItem(label: 'Sample Type', value: targetTest.sampleType),
                      _DetailItem(label: 'Collection Date', value: targetTest.appointmentDate),
                      _DetailItem(label: 'Collection Time', value: targetTest.appointmentTime),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TestStatusTimeline(
                    currentStage: targetSample.stage,
                    onStageTap: (stage) {
                      techNotifier.updateSampleStage(targetSample.sampleId, stage);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── BOTTOM START TEST BUTTON ─────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  techNotifier.updateSampleStage(targetTest.sampleId, TechSampleStage.testing);
                  context.go('/lab-tech/result-entry?sampleId=${targetTest.sampleId}');
                },
                icon: const Icon(Icons.play_arrow, size: 22),
                label: const Text(
                  'Start Test',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientInfoCard extends StatelessWidget {
  final AssignedTest test;
  final bool isDark;

  const _PatientInfoCard({required this.test, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_outline, color: Color(0xFF10B981), size: 20),
              SizedBox(width: 8),
              Text(
                'Patient Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DetailItem(label: 'Name', value: test.patientName),
          const SizedBox(height: 10),
          _DetailItem(label: 'Patient ID', value: test.patientId),
          const SizedBox(height: 10),
          _DetailItem(label: 'Age / Gender', value: test.patientAgeGender),
          const SizedBox(height: 10),
          _DetailItem(label: 'Contact', value: test.patientPhone),
        ],
      ),
    );
  }
}

class _TestInfoCard extends StatelessWidget {
  final AssignedTest test;
  final bool isDark;

  const _TestInfoCard({required this.test, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.biotech_outlined, color: Color(0xFF8B5CF6), size: 20),
              SizedBox(width: 8),
              Text(
                'Test Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DetailItem(label: 'Test Name', value: test.testName, isHighlight: true),
          const SizedBox(height: 10),
          _DetailItem(label: 'Test Category', value: test.category),
          const SizedBox(height: 10),
          _DetailItem(label: 'Assigned Date', value: test.appointmentDate),
          const SizedBox(height: 10),
          const _DetailItem(label: 'Reference Range', value: 'Standard Available'),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _DetailItem({required this.label, required this.value, this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            color: isHighlight
                ? const Color(0xFF2563EB)
                : (isDark ? Colors.white : const Color(0xFF0F172A)),
          ),
        ),
      ],
    );
  }
}
