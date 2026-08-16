import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/three_d_illustration.dart';
import '../../../models/sample_record.dart';
import '../../../services/shared_data_repository.dart';
import '../../auth/auth_provider.dart';
import '../widgets/dashboard_scaffold.dart';

class LabTechnicianDashboardScreen extends ConsumerWidget {
  const LabTechnicianDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final sharedData = ref.watch(sharedDataProvider);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    final pendingSamples = sharedData.samples.where((s) => s.status == SampleStatus.samplePending).length;
    final collectedSamples = sharedData.samples.where((s) => s.status == SampleStatus.sampleCollected).length;
    final processingSamples = sharedData.samples.where((s) => s.status == SampleStatus.processing).length;
    final submittedReports = sharedData.reports.length;

    return DashboardScaffold(
      title: 'Lab Technician Panel',
      currentRoute: '/lab-tech',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HERO BANNER WITH 3D LAB TECH ILLUSTRATION ───────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF14B8A6).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${user?.name ?? 'Priya Sharma (Lab Tech)'} 🔬',
                          style: AppTextStyles.headline1.copyWith(color: Colors.white, fontSize: 24),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Laboratory Diagnostics & Sample Processing Station • Astha Diagnostic',
                          style: AppTextStyles.subtitle.copyWith(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => context.push('/lab-tech/samples'),
                              icon: const Icon(Icons.water_drop, size: 16),
                              label: const Text('Sample Tracking & QR'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF0D9488),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => context.push('/admin/formulas'),
                              icon: const Icon(Icons.functions, size: 16),
                              label: const Text('Formula Engine'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F766E),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isDesktop) ...[
                    const SizedBox(width: 20),
                    const ThreeDIllustration(
                      type: ThreeDAssetType.labTechnician,
                      size: 140,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── DASHBOARD CARDS ──────────────────────────────────────────────
            Text('Sample & Test Queue Metrics', style: AppTextStyles.headline3.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),

            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _TechMetricCard(title: 'Pending Samples', value: '$pendingSamples', icon: Icons.pending_actions, color: const Color(0xFFF59E0B)),
                _TechMetricCard(title: 'Samples Collected', value: '$collectedSamples', icon: Icons.bloodtype, color: const Color(0xFF2563EB)),
                _TechMetricCard(title: 'In Processing', value: '$processingSamples', icon: Icons.biotech, color: const Color(0xFF14B8A6)),
                _TechMetricCard(title: 'Results Pending', value: '${sharedData.samples.length}', icon: Icons.hourglass_top, color: const Color(0xFF8B5CF6)),
                _TechMetricCard(title: 'Reports Submitted', value: '$submittedReports', icon: Icons.task_alt, color: const Color(0xFF10B981)),
              ],
            ),

            const SizedBox(height: 28),

            // ── SAMPLES WORKFLOW TABLE ──────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Assigned Laboratory Samples', style: AppTextStyles.headline3.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => context.push('/lab-tech/samples'),
                  child: const Text('View All Samples'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sharedData.samples.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final sample = sharedData.samples[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF14B8A6).withValues(alpha: 0.12),
                      child: const Icon(Icons.biotech, color: Color(0xFF14B8A6)),
                    ),
                    title: Text('${sample.testName} (${sample.sampleId})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('Patient ID: ${sample.patientId} • Sample Type: ${sample.sampleType}', style: const TextStyle(fontSize: 12)),
                    trailing: ElevatedButton(
                      onPressed: () {
                        context.push('/lab-tech/result-entry?sampleId=${sample.sampleId}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF14B8A6),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      child: const Text('Enter Results', style: TextStyle(fontSize: 12)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TechMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _TechMetricCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundColor: color.withValues(alpha: 0.12), child: Icon(icon, color: color, size: 22)),
          const SizedBox(height: 12),
          Text(value, style: AppTextStyles.headline2.copyWith(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
