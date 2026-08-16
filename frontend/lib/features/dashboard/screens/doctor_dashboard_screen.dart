import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/three_d_illustration.dart';
import '../../../services/shared_data_repository.dart';
import '../../auth/auth_provider.dart';
import '../widgets/dashboard_scaffold.dart';

class DoctorDashboardScreen extends ConsumerWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final sharedData = ref.watch(sharedDataProvider);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return DashboardScaffold(
      title: 'Doctor Panel',
      currentRoute: '/doctor',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HERO BANNER WITH 3D DOCTOR ILLUSTRATION ─────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0284C7), Color(0xFF0EA5E9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0EA5E9).withValues(alpha: 0.3),
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
                          'Good day, ${user?.name ?? 'Dr. Priya Mehta'} 🩺',
                          style: AppTextStyles.headline1.copyWith(color: Colors.white, fontSize: 24),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Senior Consultant & Medical Specialist • Astha Diagnostic',
                          style: AppTextStyles.subtitle.copyWith(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => context.push('/doctor/consultation?patientName=Rahul%20Sharma'),
                          icon: const Icon(Icons.note_add, size: 16),
                          label: const Text('Start New Consultation'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0284C7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isDesktop) ...[
                    const SizedBox(width: 20),
                    const ThreeDIllustration(
                      type: ThreeDAssetType.doctor,
                      size: 140,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── DOCTOR DASHBOARD METRICS ─────────────────────────────────────
            Text('Consultation Overview', style: AppTextStyles.headline3.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),

            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _DoctorMetricCard(title: 'Today Appointments', value: '8', icon: Icons.event_available, color: const Color(0xFF0284C7)),
                _DoctorMetricCard(title: 'Consultations Done', value: '5', icon: Icons.assignment_turned_in, color: const Color(0xFF10B981)),
                _DoctorMetricCard(title: 'Tests Recommended', value: '${sharedData.recommendedTests.length + 12}', icon: Icons.biotech, color: const Color(0xFF14B8A6)),
                _DoctorMetricCard(title: 'Patient Reports', value: '${sharedData.reports.length}', icon: Icons.folder_shared, color: const Color(0xFF8B5CF6)),
              ],
            ),

            const SizedBox(height: 28),

            // ── ASSIGNED APPOINTMENTS LIST ──────────────────────────────────
            Text("Today's Assigned Patients", style: AppTextStyles.headline3.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),

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
                itemCount: 3,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final patients = [
                    {'name': 'Rahul Sharma', 'age': '28 M', 'time': '10:00 AM', 'reason': 'Fever & Fatigue Checkup'},
                    {'name': 'Neha Singh', 'age': '34 F', 'time': '11:30 AM', 'reason': 'Thyroid Follow-up'},
                    {'name': 'Amit Kumar', 'age': '45 M', 'time': '02:00 PM', 'reason': 'Lipid & Cardiac Screening'},
                  ];
                  final p = patients[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF0284C7).withValues(alpha: 0.12),
                      child: const Icon(Icons.person, color: Color(0xFF0284C7)),
                    ),
                    title: Text('${p['name']} (${p['age']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    subtitle: Text('Time: ${p['time']} • ${p['reason']}', style: const TextStyle(fontSize: 12)),
                    trailing: ElevatedButton.icon(
                      onPressed: () {
                        context.push('/doctor/consultation?patientName=${Uri.encodeComponent(p['name']!)}');
                      },
                      icon: const Icon(Icons.edit_note, size: 16),
                      label: const Text('Consult'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
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

class _DoctorMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _DoctorMetricCard({required this.title, required this.value, required this.icon, required this.color});

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
