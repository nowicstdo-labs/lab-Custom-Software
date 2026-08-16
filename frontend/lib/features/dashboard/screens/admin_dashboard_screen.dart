import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/lab_report.dart';
import '../../../models/doctor.dart';
import '../../../services/shared_data_repository.dart';
import '../../auth/auth_provider.dart';
import '../../auth/auth_service.dart';
import '../widgets/dashboard_scaffold.dart';
import '../providers/admin_cms_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // CMS Form Controllers
  late TextEditingController _heroTitleController;
  late TextEditingController _heroSubtitleController;
  late TextEditingController _heroBtnController;
  late TextEditingController _promoTitleController;

  late TextEditingController _labNameController;
  late TextEditingController _labPhoneController;
  late TextEditingController _labEmailController;
  late TextEditingController _labAddressController;
  late TextEditingController _reportHeaderController;
  late TextEditingController _reportFooterController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);

    final cms = ref.read(adminCmsProvider);
    _heroTitleController = TextEditingController(text: cms.heroTitle);
    _heroSubtitleController = TextEditingController(text: cms.heroSubtitle);
    _heroBtnController = TextEditingController(text: cms.heroButtonText);
    _promoTitleController = TextEditingController(text: cms.promoTitle);

    _labNameController = TextEditingController(text: cms.labName);
    _labPhoneController = TextEditingController(text: cms.labPhone);
    _labEmailController = TextEditingController(text: cms.labEmail);
    _labAddressController = TextEditingController(text: cms.labAddress);
    _reportHeaderController = TextEditingController(text: cms.reportHeader);
    _reportFooterController = TextEditingController(text: cms.reportFooter);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _heroTitleController.dispose();
    _heroSubtitleController.dispose();
    _heroBtnController.dispose();
    _promoTitleController.dispose();
    _labNameController.dispose();
    _labPhoneController.dispose();
    _labEmailController.dispose();
    _labAddressController.dispose();
    _reportHeaderController.dispose();
    _reportFooterController.dispose();
    super.dispose();
  }

  void _saveHomeCms() {
    ref.read(adminCmsProvider.notifier).updateHomeCms(
          title: _heroTitleController.text.trim(),
          subtitle: _heroSubtitleController.text.trim(),
          buttonText: _heroBtnController.text.trim(),
          promoTitle: _promoTitleController.text.trim(),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Home Screen CMS saved & published to backend!'), backgroundColor: Color(0xFF00796B)),
    );
  }

  void _saveLabProfileCms() {
    ref.read(adminCmsProvider.notifier).updateLabProfile(
          name: _labNameController.text.trim(),
          phone: _labPhoneController.text.trim(),
          email: _labEmailController.text.trim(),
          address: _labAddressController.text.trim(),
          header: _reportHeaderController.text.trim(),
          footer: _reportFooterController.text.trim(),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lab Profile & Report Template branding saved!'), backgroundColor: Color(0xFF00796B)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final sharedData = ref.watch(sharedDataProvider);
    final cms = ref.watch(adminCmsProvider);
    final staffCount = MockUserDatabase.instance.staffMembers.length;
    final totalUsers = MockUserDatabase.instance.all.length;
    final pendingApprovals = sharedData.reports.where((r) => r.status == ReportStatus.readyForVerification).length;

    return DashboardScaffold(
      title: 'Admin / Lab Owner Control Panel',
      currentRoute: '/admin',
      child: Column(
        children: [
          // ── HERO GREETING BANNER ─────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF4338CA),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lab Owner CMS Control Panel 👑',
                          style: AppTextStyles.headline1.copyWith(color: Colors.white, fontSize: 22),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Welcome, ${user?.name ?? 'Admin'} • Dynamic Content, Doctors, Tests & System Governance',
                          style: AppTextStyles.subtitle.copyWith(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/admin/report-approval'),
                      icon: const Icon(Icons.verified, size: 16),
                      label: Text('Approvals ($pendingApprovals)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pendingApprovals > 0 ? const Color(0xFFF59E0B) : Colors.white,
                        foregroundColor: pendingApprovals > 0 ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── CMS NAVIGATION TABS ──────────────────────────────────────────
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: const Color(0xFF4338CA),
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: const Color(0xFF4338CA),
              tabs: const [
                Tab(icon: Icon(Icons.dashboard, size: 18), text: 'Overview'),
                Tab(icon: Icon(Icons.medical_services, size: 18), text: 'Doctor CMS'),
                Tab(icon: Icon(Icons.biotech, size: 18), text: 'Test Catalog CMS'),
                Tab(icon: Icon(Icons.home, size: 18), text: 'Home Screen CMS'),
                Tab(icon: Icon(Icons.picture_as_pdf, size: 18), text: 'Lab Profile & Report CMS'),
                Tab(icon: Icon(Icons.toggle_on, size: 18), text: 'Feature Control'),
              ],
            ),
          ),

          // ── TAB CONTENT VIEWS ─────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Overview Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Master System Metrics', style: AppTextStyles.headline3.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 14),

                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _AdminStatCard(title: 'Staff Members', value: '$staffCount', icon: Icons.badge, color: const Color(0xFF6366F1)),
                          _AdminStatCard(title: 'Total Patients', value: '${totalUsers - staffCount + 120}', icon: Icons.groups, color: const Color(0xFF2563EB)),
                          _AdminStatCard(title: 'Report Approvals Queue', value: '$pendingApprovals', icon: Icons.approval, color: const Color(0xFFF59E0B)),
                          _AdminStatCard(title: 'Formulas Configured', value: '${sharedData.formulas.length}', icon: Icons.functions, color: const Color(0xFF14B8A6)),
                          _AdminStatCard(title: 'Total Invoices', value: '${sharedData.invoices.length}', icon: Icons.receipt_long, color: const Color(0xFF10B981)),
                          _AdminStatCard(title: 'Audit Logs Recorded', value: '${sharedData.auditLogs.length}', icon: Icons.security, color: const Color(0xFF8B5CF6)),
                        ],
                      ),

                      const SizedBox(height: 28),

                      Text('Quick Operations', style: AppTextStyles.headline3.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 14),

                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _ActionChip(icon: Icons.approval, label: 'Report Approval Queue', onTap: () => context.push('/admin/report-approval')),
                          _ActionChip(icon: Icons.functions, label: 'Formula Engine', onTap: () => context.push('/admin/formulas')),
                          _ActionChip(icon: Icons.person_add, label: 'Add Staff', onTap: () => context.push('/admin/add-staff')),
                          _ActionChip(icon: Icons.receipt, label: 'Billing & Invoices', onTap: () => context.push('/billing')),
                          _ActionChip(icon: Icons.search, label: 'Global Search', onTap: () => context.push('/global-search')),
                          _ActionChip(icon: Icons.security, label: 'Audit Log', onTap: () => context.push('/audit-log')),
                        ],
                      ),
                    ],
                  ),
                ),

                // 2. Doctor CMS Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Doctor Directory CMS (${cms.doctors.length} Doctors)', style: AppTextStyles.headline3.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                          ElevatedButton.icon(
                            onPressed: () => _showEditDoctorDialog(context, null),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add New Doctor'),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00796B)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cms.doctors.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, idx) {
                          final doc = cms.doctors[idx];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                  child: const Icon(Icons.person, color: AppColors.primary),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(doc.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      Text('${doc.specialization} • ${doc.qualification}', style: const TextStyle(fontSize: 12, color: AppColors.primary)),
                                      Text('Fee: ${doc.consultationFee} • Exp: ${doc.experience}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: AppColors.primary),
                                  onPressed: () => _showEditDoctorDialog(context, doc),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // 3. Test Catalog CMS Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Test Catalog & Pricing CMS (${cms.tests.length} Tests)', style: AppTextStyles.headline3.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                          ElevatedButton.icon(
                            onPressed: () => _showEditTestDialog(context, null),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Diagnostic Test'),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00796B)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cms.tests.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, idx) {
                          final t = cms.tests[idx];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: const Color(0xFF14B8A6).withValues(alpha: 0.1),
                                  child: const Icon(Icons.biotech, color: Color(0xFF14B8A6)),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      Text('ID: ${t.id} • Category: ${t.category}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                      Text(t.description, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                                Text('₹ ${t.price.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF00796B))),
                                const SizedBox(width: 12),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: AppColors.primary),
                                  onPressed: () => _showEditTestDialog(context, t),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // 4. Home Screen CMS Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Patient Home Screen Content Builder', style: AppTextStyles.headline3.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 14),

                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          children: [
                            TextField(
                              controller: _heroTitleController,
                              decoration: const InputDecoration(labelText: 'Hero Banner Title', border: OutlineInputBorder()),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _heroSubtitleController,
                              maxLines: 2,
                              decoration: const InputDecoration(labelText: 'Hero Banner Subtitle', border: OutlineInputBorder()),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _heroBtnController,
                              decoration: const InputDecoration(labelText: 'Hero Button Text', border: OutlineInputBorder()),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _promoTitleController,
                              decoration: const InputDecoration(labelText: 'Promotional Banner Text', border: OutlineInputBorder()),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: ElevatedButton.icon(
                                onPressed: _saveHomeCms,
                                icon: const Icon(Icons.save),
                                label: const Text('Save & Publish Home CMS'),
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00796B)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 5. Lab Profile & Report Template CMS Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lab Branding & Report PDF Template CMS', style: AppTextStyles.headline3.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 14),

                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          children: [
                            TextField(controller: _labNameController, decoration: const InputDecoration(labelText: 'Laboratory Name', border: OutlineInputBorder())),
                            const SizedBox(height: 12),
                            TextField(controller: _labPhoneController, decoration: const InputDecoration(labelText: 'Lab Contact Phone', border: OutlineInputBorder())),
                            const SizedBox(height: 12),
                            TextField(controller: _labEmailController, decoration: const InputDecoration(labelText: 'Lab Support Email', border: OutlineInputBorder())),
                            const SizedBox(height: 12),
                            TextField(controller: _labAddressController, decoration: const InputDecoration(labelText: 'Lab Address', border: OutlineInputBorder())),
                            const SizedBox(height: 12),
                            TextField(controller: _reportHeaderController, decoration: const InputDecoration(labelText: 'Printable Report Header', border: OutlineInputBorder())),
                            const SizedBox(height: 12),
                            TextField(controller: _reportFooterController, decoration: const InputDecoration(labelText: 'Printable Report Footer', border: OutlineInputBorder())),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: ElevatedButton.icon(
                                onPressed: _saveLabProfileCms,
                                icon: const Icon(Icons.save),
                                label: const Text('Save Lab Branding & Templates'),
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00796B)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 6. Feature Control Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('System Feature Control Switches', style: AppTextStyles.headline3.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 14),

                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          children: cms.features.entries.map((e) {
                            return SwitchListTile(
                              title: Text(e.key.replaceAll(RegExp(r'([A-Z])'), ' \$1').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              subtitle: Text(e.value ? 'Enabled for public & staff' : 'Disabled / Suspended by Admin'),
                              value: e.value,
                              activeThumbColor: const Color(0xFF00796B),
                              onChanged: (val) {
                                ref.read(adminCmsProvider.notifier).toggleFeature(e.key, val);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDoctorDialog(BuildContext context, Doctor? doc) {
    final nameCtrl = TextEditingController(text: doc?.name ?? '');
    final specCtrl = TextEditingController(text: doc?.specialization ?? 'General Physician');
    final qualCtrl = TextEditingController(text: doc?.qualification ?? 'MBBS, MD');
    final feeCtrl = TextEditingController(text: doc?.consultationFee ?? '₹ 500');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(doc == null ? 'Add New Doctor' : 'Edit Doctor Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Doctor Name')),
            TextField(controller: specCtrl, decoration: const InputDecoration(labelText: 'Specialization')),
            TextField(controller: qualCtrl, decoration: const InputDecoration(labelText: 'Qualification')),
            TextField(controller: feeCtrl, decoration: const InputDecoration(labelText: 'Consultation Fee')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newDoc = Doctor(
                id: doc?.id ?? 'doc-${DateTime.now().millisecondsSinceEpoch}',
                name: nameCtrl.text.trim(),
                specialization: specCtrl.text.trim(),
                qualification: qualCtrl.text.trim(),
                experience: doc?.experience ?? '8+ Years',
                about: doc?.about ?? 'Senior Diagnostic Specialist.',
                rating: doc?.rating ?? 4.9,
                patientsServed: doc?.patientsServed ?? 500,
                consultationFee: feeCtrl.text.trim(),
                availability: doc?.availability ?? 'Mon - Sat',
              );
              ref.read(adminCmsProvider.notifier).updateDoctor(newDoc);
              Navigator.pop(context);
            },
            child: const Text('Save Doctor'),
          ),
        ],
      ),
    );
  }

  void _showEditTestDialog(BuildContext context, DiagnosticTestModel? test) {
    final nameCtrl = TextEditingController(text: test?.name ?? '');
    final catCtrl = TextEditingController(text: test?.category ?? 'Blood Tests');
    final priceCtrl = TextEditingController(text: test?.price.toString() ?? '500');
    final descCtrl = TextEditingController(text: test?.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(test == null ? 'Add Diagnostic Test' : 'Edit Diagnostic Test'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Test Name')),
            TextField(controller: catCtrl, decoration: const InputDecoration(labelText: 'Category')),
            TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Price (₹)')),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newTest = DiagnosticTestModel(
                id: test?.id ?? 'TEST-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                name: nameCtrl.text.trim(),
                category: catCtrl.text.trim(),
                price: double.tryParse(priceCtrl.text.trim()) ?? 500,
                description: descCtrl.text.trim(),
                tat: test?.tat ?? '24 Hours',
              );
              ref.read(adminCmsProvider.notifier).updateTest(newTest);
              Navigator.pop(context);
            },
            child: const Text('Save Test'),
          ),
        ],
      ),
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _AdminStatCard({required this.title, required this.value, required this.icon, required this.color});

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
    return ActionChip(
      avatar: Icon(icon, size: 16, color: const Color(0xFF4338CA)),
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      backgroundColor: Colors.white,
      onPressed: onTap,
    );
  }
}
