import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../auth/auth_provider.dart';
import '../providers/patient_profile_provider.dart';

class PatientProfileScreen extends ConsumerStatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  ConsumerState<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends ConsumerState<PatientProfileScreen> {
  int _bottomNavIndex = 3; // Profile active tab

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(patientProfileProvider.notifier).fetchPatientProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authProvider.select((s) => s.user));
    final profile = ref.watch(patientProfileProvider);
    final displayName = profile.fullName.isNotEmpty ? profile.fullName : (authUser?.name ?? '');
    final patientIdText = profile.patientId.isNotEmpty ? profile.patientId : (authUser?.id ?? '');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Top Header Section (Teal Background) ─────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 36),
              decoration: const BoxDecoration(
                color: Color(0xFF00796B),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  // Title + Notification Icon Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 32),
                      Text(
                        'My Profile',
                        style: AppTextStyles.headline3.copyWith(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
                            onPressed: () {},
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Text(
                                '3',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Patient Avatar + Info Row
                  GestureDetector(
                    onTap: () => context.push('/public/profile-info'),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/doctor_male_1.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Patient details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: AppTextStyles.headline2.copyWith(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (patientIdText.isNotEmpty)
                                Row(
                                  children: [
                                    Text(
                                      'Patient ID: $patientIdText',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.copy_outlined,
                                      color: Colors.white.withValues(alpha: 0.85),
                                      size: 13,
                                    ),
                                  ],
                                ),

                              const SizedBox(height: 6),
                              if (profile.isVerified)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle_rounded, color: Colors.white, size: 12),
                                      SizedBox(width: 4),
                                      Text(
                                        'Verified',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── 4 Quick Access Cards Row ──────────────────────────────────────
            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _QuickAccessCard(
                      icon: Icons.calendar_month_outlined,
                      title: 'My Appointments',
                      count: '05',
                      iconColor: const Color(0xFF1565C0),
                      onTap: () => context.push('/public/appointments'),
                    ),
                    const SizedBox(width: 10),
                    _QuickAccessCard(
                      icon: Icons.description_outlined,
                      title: 'My Reports',
                      count: '08',
                      iconColor: const Color(0xFF00796B),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Opening My Reports...')),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    _QuickAccessCard(
                      icon: Icons.biotech_outlined,
                      title: 'My Tests',
                      count: '12',
                      iconColor: const Color(0xFF6A1B9A),
                      onTap: () => context.push('/public/my-tests'),
                    ),
                    const SizedBox(width: 10),
                    _QuickAccessCard(
                      icon: Icons.receipt_long_outlined,
                      title: 'My Bills',
                      count: '04',
                      iconColor: const Color(0xFF0277BD),
                      onTap: () => context.push('/public/my-bills'),
                    ),
                  ],
                ),
              ),
            ),

            // ── Profile Menu List ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _ProfileMenuItem(
                      icon: Icons.person_outline_rounded,
                      iconBgColor: const Color(0xFFE3F2FD),
                      iconColor: const Color(0xFF1565C0),
                      title: 'Profile Information',
                      subtitle: 'Personal and contact details',
                      onTap: () => context.push('/public/profile-info'),
                    ),
                    _MenuDivider(),
                    _ProfileMenuItem(
                      icon: Icons.people_outline_rounded,
                      iconBgColor: const Color(0xFFE8F5E9),
                      iconColor: const Color(0xFF2E7D32),
                      title: 'Family Members',
                      subtitle: 'Manage family profiles',
                      onTap: () => context.push('/public/family-members'),
                    ),
                    _MenuDivider(),
                    _ProfileMenuItem(
                      icon: Icons.location_on_outlined,
                      iconBgColor: const Color(0xFFF3E5F5),
                      iconColor: const Color(0xFF7B1FA2),
                      title: 'Address Book',
                      subtitle: 'Manage saved addresses',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Address Book opened')),
                        );
                      },
                    ),
                    _MenuDivider(),
                    _ProfileMenuItem(
                      icon: Icons.credit_card_outlined,
                      iconBgColor: const Color(0xFFE0F7FA),
                      iconColor: const Color(0xFF00838F),
                      title: 'Payment Methods',
                      subtitle: 'Saved cards and UPI',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Payment Methods opened')),
                        );
                      },
                    ),
                    _MenuDivider(),
                    _ProfileMenuItem(
                      icon: Icons.notifications_none_rounded,
                      iconBgColor: const Color(0xFFFFF3E0),
                      iconColor: const Color(0xFFE65100),
                      title: 'Notifications',
                      subtitle: 'Manage notification preferences',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Notification settings opened')),
                        );
                      },
                    ),
                    _MenuDivider(),
                    _ProfileMenuItem(
                      icon: Icons.medical_services_outlined,
                      iconBgColor: const Color(0xFFE8F7F5),
                      iconColor: const Color(0xFF00796B),
                      title: 'Health Summary',
                      subtitle: 'View basic health summary',
                      onTap: () => context.push('/public/health-summary'),
                    ),
                    _MenuDivider(),
                    _ProfileMenuItem(
                      icon: Icons.help_outline_rounded,
                      iconBgColor: const Color(0xFFEFEBE9),
                      iconColor: const Color(0xFF4E342E),
                      title: 'Help & Support',
                      subtitle: 'FAQs, support and contact us',
                      onTap: () => context.push('/public/help-support'),
                    ),
                    _MenuDivider(),
                    _ProfileMenuItem(
                      icon: Icons.settings_outlined,
                      iconBgColor: const Color(0xFFECEFF1),
                      iconColor: const Color(0xFF37474F),
                      title: 'Settings',
                      subtitle: 'App settings and preferences',
                      onTap: () => context.push('/public/settings'),
                    ),
                    _MenuDivider(),
                    _ProfileMenuItem(
                      icon: Icons.logout_rounded,
                      iconBgColor: const Color(0xFFFFEBEE),
                      iconColor: const Color(0xFFD32F2F),
                      title: 'Logout',
                      subtitle: 'Sign out of your account',
                      isLogout: true,
                      onTap: () {
                        ref.read(authProvider.notifier).logout();
                        context.go('/login');
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),

      // ── Bottom Navigation Bar (4 Items) ───────────────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _bottomNavIndex,
          onTap: (index) {
            setState(() => _bottomNavIndex = index);
            if (index == 0) {
              context.go('/patient');
            } else if (index == 1) {
              context.push('/public/appointments');
            } else if (index == 2) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening Reports viewer...')),
              );
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF00796B),
          unselectedItemColor: AppColors.textSecondary,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              label: 'Appointments',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick Access Card Component ──────────────────────────────────────────────

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String count;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.title,
    required this.count,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTextStyles.body.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                count,
                style: AppTextStyles.headline3.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Menu Item Component ───────────────────────────────────────────────────────

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isLogout;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.isLogout = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isLogout ? const Color(0xFFD32F2F) : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 11,
          color: AppColors.textSecondary.withValues(alpha: 0.8),
        ),
      ),
      trailing: isLogout
          ? null
          : Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              size: 20,
            ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 0.5, indent: 56, endIndent: 16);
  }
}
