import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/primary_button.dart';

class TestDetailsScreen extends StatelessWidget {
  const TestDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Details')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Complete Blood Count', style: AppTextStyles.headline2),
          const SizedBox(height: 10),
          Text('A comprehensive hematology test for complete wellness screening.', style: AppTextStyles.subtitle),
          const SizedBox(height: 24),
          Row(children: [
            _DetailTile(label: 'Category', value: 'Hematology'),
            const SizedBox(width: 16),
            _DetailTile(label: 'Turnaround', value: '24 hrs'),
          ]),
          const SizedBox(height: 24),
          Text('Preparation', style: AppTextStyles.headline3),
          const SizedBox(height: 10),
          Text('No fasting required. Maintain hydration and arrive 10 minutes early for a smooth sample collection.', style: AppTextStyles.body.copyWith(height: 1.6)),
          const SizedBox(height: 24),
          Text('Included analyses', style: AppTextStyles.headline3),
          const SizedBox(height: 12),
          Wrap(spacing: 12, runSpacing: 12, children: const [
            Chip(label: Text('WBC')), Chip(label: Text('RBC')), Chip(label: Text('Hemoglobin')), Chip(label: Text('Platelets')),
          ]),
          const Spacer(),
          PrimaryButton(label: 'Book this test', onPressed: () => context.go('/public/book-test')),
        ]),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final String label;
  final String value;

  const _DetailTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppTextStyles.subtitle),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.headline3.copyWith(fontSize: 20)),
        ]),
      ),
    );
  }
}
