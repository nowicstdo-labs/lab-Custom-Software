import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/animated_pressable.dart';
import '../../../core/widgets/three_d_illustration.dart';
import '../../../models/lab_report.dart';
import '../../../services/shared_data_repository.dart';
import '../../auth/auth_provider.dart';
import '../widgets/dashboard_scaffold.dart';

class ReceptionistDashboardScreen extends ConsumerStatefulWidget {
  const ReceptionistDashboardScreen({super.key});

  @override
  ConsumerState<ReceptionistDashboardScreen> createState() => _ReceptionistDashboardScreenState();
}

class _ReceptionistDashboardScreenState extends ConsumerState<ReceptionistDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(sharedDataProvider.notifier).fetchBookingsFromBackend();
    });
  }

  Future<void> _refresh() async {
    await ref.read(sharedDataProvider.notifier).fetchBookingsFromBackend();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Refreshed latest bookings queue'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final sharedData = ref.watch(sharedDataProvider);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return DashboardScaffold(
      title: 'Receptionist Dashboard',
      currentRoute: '/receptionist',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.primary),
          tooltip: 'Refresh Bookings Queue',
          onPressed: _refresh,
        ),
      ],
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── HERO BANNER WITH 3D RECEPTIONIST ILLUSTRATION ─────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.3),
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
                            'Welcome Back, ${user?.name ?? 'Anjali Sharma'} 👋',
                            style: AppTextStyles.headline1.copyWith(color: Colors.white, fontSize: 24),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Receptionist & Patient Care Desk • Astha Diagnostic Center',
                            style: AppTextStyles.subtitle.copyWith(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => context.push('/public/book-test'),
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('New Booking'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF14B8A6),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => context.push('/billing'),
                                icon: const Icon(Icons.receipt_long, size: 16),
                                label: const Text('Create Invoice'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.primary,
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
                        type: ThreeDAssetType.receptionist,
                        size: 140,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── DASHBOARD METRICS CARDS ──────────────────────────────────────
              Text('Daily Lab Overview', style: AppTextStyles.headline3.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),

              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _StatCard(title: "Today's Patients", value: '${sharedData.bookings.length + 45}', icon: Icons.groups, color: const Color(0xFF2563EB)),
                  _StatCard(title: 'Test Bookings', value: '${sharedData.bookings.length}', icon: Icons.biotech, color: const Color(0xFF14B8A6)),
                  _StatCard(title: 'Doctor Consults', value: '15', icon: Icons.medical_services, color: const Color(0xFF0284C7)),
                  _StatCard(title: 'Reports Ready', value: '${sharedData.reports.where((r) => r.status == ReportStatus.approved).length}', icon: Icons.description, color: const Color(0xFF10B981)),
                  _StatCard(title: 'Pending Payments', value: '₹14,200', icon: Icons.payments, color: const Color(0xFFF59E0B)),
                ],
              ),

              const SizedBox(height: 28),

              // ── QUICK ACTION TOOLBAR ─────────────────────────────────────────
              Text('Quick Operations', style: AppTextStyles.headline3.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _ActionChip(icon: Icons.add_circle, label: 'Book Test', onTap: () => context.push('/public/book-test')),
                  _ActionChip(icon: Icons.person_add, label: 'Add Patient', onTap: () => context.push('/patients')),
                  _ActionChip(icon: Icons.qr_code_scanner, label: 'Scan Patient / QR', onTap: () => context.push('/lab-tech/scanner')),
                  _ActionChip(icon: Icons.water_drop, label: 'Sample Entry', onTap: () => context.push('/lab-tech/samples')),
                  _ActionChip(icon: Icons.receipt, label: 'Billing / Invoice', onTap: () => context.push('/billing')),
                  _ActionChip(icon: Icons.search, label: 'Global Search', onTap: () => context.push('/global-search')),
                  _ActionChip(icon: Icons.edit_document, label: 'Report Builder', onTap: () => context.push('/report-builder')),
                ],
              ),

              const SizedBox(height: 28),

              // ── RECENT BOOKINGS & RECEPTIONIST TABLE ─────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Bookings Queue', style: AppTextStyles.headline3.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF00796B)),
                    tooltip: 'Refresh Queue',
                    onPressed: _refresh,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: sharedData.bookings.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.inbox_outlined, size: 48, color: AppColors.textSecondary),
                              const SizedBox(height: 12),
                              Text(
                                'No Bookings Found',
                                style: AppTextStyles.headline3.copyWith(fontSize: 16, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Live patient test bookings from the database will appear here.',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sharedData.bookings.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final b = sharedData.bookings[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                              child: const Icon(Icons.person, color: AppColors.primary),
                            ),
                            title: Text(
                              '${b.patientName} (${b.patientId})',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            subtitle: Text(
                              'ID: ${b.bookingId} • ${b.testName}\n${b.appointmentDate} (${b.appointmentTime})',
                              style: const TextStyle(fontSize: 12, height: 1.3),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2F1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                b.bookingStatus,
                                style: const TextStyle(color: Color(0xFF00796B), fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                            onTap: () => context.push('/public/my-tests'),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

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

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedPressable(
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
          ],
        ),
      ),
    );
  }
}
