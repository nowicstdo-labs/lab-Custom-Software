import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../providers/patient_profile_provider.dart';

class ProfileInfoScreen extends ConsumerWidget {
  const ProfileInfoScreen({super.key});

  int _calculateAge(String dobStr) {
    try {
      final parts = dobStr.split('-');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        final dob = DateTime(year, month, day);
        final now = DateTime.now();
        int age = now.year - dob.year;
        if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
          age--;
        }
        return age > 0 ? age : 28;
      }
    } catch (_) {}
    return 28;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(patientProfileProvider);
    final ageYears = _calculateAge(profile.dob);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Profile Information',
          style: AppTextStyles.headline3.copyWith(
            fontSize: 18,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => context.push('/public/edit-profile'),
            child: const Text(
              'Edit',
              style: TextStyle(
                color: Color(0xFF00796B),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Section 1: Personal Information ────────────────────────────
            _InfoSectionCard(
              title: 'Personal Information',
              rows: [
                _InfoTile(icon: Icons.person_outline, label: 'Full Name', value: profile.fullName),
                _InfoTile(icon: Icons.badge_outlined, label: 'Patient ID', value: profile.patientId),
                _InfoTile(icon: Icons.cake_outlined, label: 'Date of Birth', value: profile.dob),
                _InfoTile(icon: Icons.calendar_month_outlined, label: 'Age', value: '$ageYears Years'),
                _InfoTile(icon: Icons.transgender_outlined, label: 'Gender', value: profile.gender),
                _InfoTile(icon: Icons.water_drop_outlined, label: 'Blood Group', value: profile.bloodGroup),
              ],
            ),

            const SizedBox(height: 16),

            // ── Section 2: Contact Information ─────────────────────────────
            _InfoSectionCard(
              title: 'Contact Information',
              rows: [
                _InfoTile(icon: Icons.phone_outlined, label: 'Phone Number', value: profile.phone),
                _InfoTile(icon: Icons.email_outlined, label: 'Email', value: profile.email),
                _InfoTile(icon: Icons.phone_android_outlined, label: 'Alternate Number', value: profile.alternateNumber),
              ],
            ),

            const SizedBox(height: 16),

            // ── Section 3: Address Information ─────────────────────────────
            _InfoSectionCard(
              title: 'Address Information',
              rows: [
                _InfoTile(icon: Icons.location_on_outlined, label: 'Address', value: profile.address),
              ],
            ),

            const SizedBox(height: 16),

            // ── Section 4: Emergency Contact ───────────────────────────────
            _InfoSectionCard(
              title: 'Emergency Contact',
              rows: [
                _InfoTile(icon: Icons.person_pin_outlined, label: 'Contact Name', value: profile.emergencyName),
                _InfoTile(icon: Icons.family_restroom_outlined, label: 'Relationship', value: profile.emergencyRelationship),
                _InfoTile(icon: Icons.phone_in_talk_outlined, label: 'Phone Number', value: profile.emergencyPhone),
              ],
            ),

            const SizedBox(height: 24),

            // Edit Profile Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/public/edit-profile'),
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                label: const Text(
                  'Edit Profile',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00796B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InfoSectionCard extends StatelessWidget {
  final String title;
  final List<Widget> rows;

  const _InfoSectionCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.headline3.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF00796B)),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
