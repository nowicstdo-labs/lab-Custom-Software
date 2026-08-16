import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../auth/auth_provider.dart';

class PatientDashboardScreen extends ConsumerStatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  ConsumerState<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends ConsumerState<PatientDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final patientName = user != null ? user.name.split(' ').first : 'Rahul';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Bar ─────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary, size: 26),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Menu drawer opened')),
                      );
                    },
                  ),
                  // Logo + Title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.biotech, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Astha',
                            style: AppTextStyles.headline3.copyWith(
                              fontSize: 18,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            'DIAGNOSTIC',
                            style: AppTextStyles.body.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: AppColors.secondary,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Notification + Profile
                  Row(
                    children: [
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: 24),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('No new notifications')),
                              );
                            },
                          ),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                        backgroundImage: const AssetImage('assets/images/doctor_male_1.png'),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Greeting Banner ────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEBF4FF), Color(0xFFE6F7F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Hello, $patientName',
                                style: AppTextStyles.headline2.copyWith(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text('👋', style: TextStyle(fontSize: 20)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Take charge of your health today',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: Image.asset(
                        'assets/images/shield_health_icon.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.verified_user,
                          color: AppColors.secondary,
                          size: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Search Bar ─────────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onSubmitted: (q) {
                          if (q.isNotEmpty) context.push('/public/tests');
                        },
                        decoration: InputDecoration(
                          hintText: 'Search tests, doctors, & more...',
                          hintStyle: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/public/tests'),
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.search, color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Section Header ─────────────────────────────────────────────
              Text(
                'What would you like to do?',
                style: AppTextStyles.headline3.copyWith(
                  fontSize: 17,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),

              // ── TWO MAIN SIDE-BY-SIDE CARDS ───────────────────────────────
              Row(
                children: [
                  // CARD 1: Book a Test
                  Expanded(
                    child: _MainOptionCard(
                      title: 'Book a Test',
                      subtitle: 'Book lab tests and get accurate reports',
                      backgroundColor: const Color(0xFFEEF5FF),
                      titleColor: const Color(0xFF1565C0),
                      buttonColor: const Color(0xFF1565C0),
                      imagePath: 'assets/images/test_tubes_rack.png',
                      onTap: () => context.push('/public/book-test'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // CARD 2: Doctor Appointment
                  Expanded(
                    child: _MainOptionCard(
                      title: 'Doctor Appointment',
                      subtitle: 'Consult with expert doctors',
                      backgroundColor: const Color(0xFFE8F7F5),
                      titleColor: const Color(0xFF00796B),
                      buttonColor: const Color(0xFF00796B),
                      imagePath: 'assets/images/stethoscope_icon.png',
                      onTap: () => context.push('/public/book-appointment'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── UPCOMING APPOINTMENT ───────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upcoming Appointment',
                    style: AppTextStyles.headline3.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/public/appointments'),
                    child: Text(
                      'View all',
                      style: AppTextStyles.body.copyWith(
                        color: const Color(0xFF1565C0),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2F1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.event_note, color: Color(0xFF00796B), size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CBC Blood Test',
                            style: AppTextStyles.headline3.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '25 May 2025 • 10:30 AM',
                            style: AppTextStyles.body.copyWith(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Astha Diagnostic Center',
                            style: AppTextStyles.body.copyWith(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Confirmed',
                        style: TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── POPULAR TESTS ──────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Popular Tests',
                    style: AppTextStyles.headline3.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/public/tests'),
                    child: Text(
                      'View all',
                      style: AppTextStyles.body.copyWith(
                        color: const Color(0xFF1565C0),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CategoryShortcutCard(
                    icon: Icons.water_drop_outlined,
                    iconColor: Colors.red.shade400,
                    label: 'Blood Tests',
                    onTap: () => context.push('/public/tests'),
                  ),
                  _CategoryShortcutCard(
                    icon: Icons.science_outlined,
                    iconColor: Colors.blue.shade600,
                    label: 'Biochemistry',
                    onTap: () => context.push('/public/tests'),
                  ),
                  _CategoryShortcutCard(
                    icon: Icons.biotech_outlined,
                    iconColor: Colors.purple.shade400,
                    label: 'Microbiology',
                    onTap: () => context.push('/public/tests'),
                  ),
                  _CategoryShortcutCard(
                    icon: Icons.favorite_outline,
                    iconColor: Colors.pink.shade400,
                    label: 'Health Packages',
                    onTap: () => context.push('/public/packages'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // ── BOTTOM NAVIGATION (4 ITEMS) ───────────────────────────────────────
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
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() => _selectedIndex = index);
            if (index == 1) {
              context.push('/public/my-tests');
            } else if (index == 2) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Downloading patient lab reports...')),
              );
            } else if (index == 3) {
              context.push('/public/profile');
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF1565C0),
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
              icon: Icon(Icons.biotech_rounded),
              label: 'My Tests',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ── Main Option Card (Book a Test / Doctor Appointment) ──────────────────────

class _MainOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color titleColor;
  final Color buttonColor;
  final String imagePath;
  final VoidCallback onTap;

  const _MainOptionCard({
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.titleColor,
    required this.buttonColor,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            // Top Illustration
            SizedBox(
              height: 75,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.medical_services,
                  size: 50,
                  color: titleColor.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Title
            Text(
              title,
              style: AppTextStyles.headline3.copyWith(
                color: titleColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            // Subtitle
            Text(
              subtitle,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),
            // Circle Arrow Button
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: buttonColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Category Shortcut Card ───────────────────────────────────────────────────

class _CategoryShortcutCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _CategoryShortcutCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 26),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
