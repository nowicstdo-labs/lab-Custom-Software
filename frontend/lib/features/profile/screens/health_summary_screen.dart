import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../providers/patient_profile_provider.dart';

class HealthSummaryScreen extends ConsumerWidget {
  const HealthSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(patientProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Health Summary',
          style: AppTextStyles.headline3.copyWith(
            fontSize: 18,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Grid (2 columns)
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _HealthMetricTile(
                  icon: Icons.straighten_outlined,
                  label: 'Height',
                  value: profile.height,
                  iconColor: const Color(0xFF00838F),
                  bgColor: const Color(0xFFE0F7FA),
                ),
                _HealthMetricTile(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Weight',
                  value: profile.weight,
                  iconColor: const Color(0xFFE65100),
                  bgColor: const Color(0xFFFFF3E0),
                ),
                _HealthMetricTile(
                  icon: Icons.speed_outlined,
                  label: 'BMI',
                  value: profile.bmi,
                  badge: profile.bmiStatus,
                  iconColor: const Color(0xFF2E7D32),
                  bgColor: const Color(0xFFE8F5E9),
                ),
                _HealthMetricTile(
                  icon: Icons.water_drop_outlined,
                  label: 'Blood Group',
                  value: profile.bloodGroup,
                  iconColor: const Color(0xFFD32F2F),
                  bgColor: const Color(0xFFFFEBEE),
                ),
                _HealthMetricTile(
                  icon: Icons.event_note_outlined,
                  label: 'Last Checkup',
                  value: profile.lastCheckup,
                  iconColor: const Color(0xFF6A1B9A),
                  bgColor: const Color(0xFFF3E5F5),
                ),
                _HealthMetricTile(
                  icon: Icons.coronavirus_outlined,
                  label: 'Allergies',
                  value: profile.allergies,
                  iconColor: const Color(0xFFC62828),
                  bgColor: const Color(0xFFFFEBEE),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Chronic Conditions
            _HealthDetailCard(
              icon: Icons.access_time_filled_outlined,
              iconColor: const Color(0xFF0277BD),
              title: 'Chronic Conditions',
              description: 'No chronic conditions recorded.',
            ),

            const SizedBox(height: 14),

            // Current Medications
            _HealthDetailCard(
              icon: Icons.medication_outlined,
              iconColor: const Color(0xFFD84315),
              title: 'Current Medications',
              description: 'No medications currently added.',
            ),

            const SizedBox(height: 24),

            // Disclaimer Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF00796B), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This summary displays basic profile information provided by the system. It does not constitute a medical diagnosis.',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _HealthMetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? badge;
  final Color iconColor;
  final Color bgColor;

  const _HealthMetricTile({
    required this.icon,
    required this.label,
    required this.value,
    this.badge,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 8.5, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 10, color: AppColors.textSecondary.withValues(alpha: 0.8))),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _HealthDetailCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _HealthDetailCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.headline3.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(description, style: TextStyle(fontSize: 12, color: AppColors.textSecondary.withValues(alpha: 0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
