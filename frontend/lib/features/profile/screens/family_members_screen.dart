import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';

class FamilyMember {
  final String name;
  final String relationship;
  final String dob;
  final String phone;

  const FamilyMember({
    required this.name,
    required this.relationship,
    required this.dob,
    required this.phone,
  });
}

class FamilyMembersScreen extends StatefulWidget {
  const FamilyMembersScreen({super.key});

  @override
  State<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends State<FamilyMembersScreen> {
  final List<FamilyMember> _familyMembers = [
    const FamilyMember(
      name: 'Suresh Kumar',
      relationship: 'Father',
      dob: '01-01-1968',
      phone: '+91 98765 00000',
    ),
    const FamilyMember(
      name: 'Sunita Devi',
      relationship: 'Mother',
      dob: '15-04-1972',
      phone: '+91 98765 00001',
    ),
    const FamilyMember(
      name: 'Priya Kumari',
      relationship: 'Sister',
      dob: '20-08-2001',
      phone: '+91 98765 00002',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Family Members',
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
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add Family Member modal opened')),
              );
            },
            icon: const Icon(Icons.add, color: Color(0xFF00796B), size: 18),
            label: const Text(
              'Add',
              style: TextStyle(color: Color(0xFF00796B), fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _familyMembers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, i) {
          final member = _familyMembers[i];
          final initial = member.name.split(' ').first[0];
          return Container(
            padding: const EdgeInsets.all(16),
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
            child: Row(
              children: [
                // Avatar with initial letter
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF00796B).withValues(alpha: 0.1),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00796B),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Member details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: AppTextStyles.headline3.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        member.relationship,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF00796B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'DOB: ${member.dob}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        member.phone,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 22),
              ],
            ),
          );
        },
      ),
    );
  }
}
