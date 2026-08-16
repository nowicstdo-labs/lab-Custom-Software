import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/section_header.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Astha Diagnostic')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'About Astha Diagnostic', subtitle: 'A premium diagnostic laboratory platform built for hospitals, clinics and labs.'),
            const SizedBox(height: 22),
            Container(
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.all(24),
              child: Text(
                'Astha Diagnostic delivers enterprise-grade laboratory and healthcare workflows with professional role-based dashboards, secure patient management, and easy appointment booking. Designed for cross-platform deployment on mobile, web, and desktop, the frontend is ready to integrate with REST APIs and backend services.',
                style: AppTextStyles.body.copyWith(height: 1.6),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(spacing: 20, runSpacing: 20, children: [
              _StatTile(label: '500+', value: 'Healthcare partners'),
              _StatTile(label: '5 roles', value: 'Role-based access'),
              _StatTile(label: '250K', value: 'Patients managed'),
            ]),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.08), blurRadius: 22, offset: const Offset(0, 10))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: AppTextStyles.headline3.copyWith(fontSize: 28)),
        const SizedBox(height: 8),
        Text(label, style: AppTextStyles.subtitle),
      ]),
    );
  }
}
