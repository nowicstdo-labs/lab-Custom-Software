import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/health_package.dart';
import '../../../utils/dummy_data.dart';
import '../../../core/widgets/primary_button.dart';

class HealthPackagesScreen extends StatelessWidget {
  const HealthPackagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Packages')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Care packages for every need', style: AppTextStyles.headline2),
          const SizedBox(height: 10),
          Text('Curated preventive care and diagnostic packages for individuals and families.', style: AppTextStyles.subtitle),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: demoHealthPackages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final package = demoHealthPackages[index];
                return _PackageCard(healthPackage: package);
              },
            ),
          ),
        ]),
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final HealthPackage healthPackage;

  const _PackageCard({required this.healthPackage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 12))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(healthPackage.name, style: AppTextStyles.headline3.copyWith(fontSize: 22)),
          Text('₹${healthPackage.price.toStringAsFixed(0)}', style: AppTextStyles.headline3.copyWith(color: AppColors.primary)),
        ]),
        const SizedBox(height: 10),
        Text(healthPackage.description, style: AppTextStyles.body),
        const SizedBox(height: 18),
        Wrap(spacing: 12, children: healthPackage.includes.map((item) => Chip(label: Text(item))).toList()),
        const SizedBox(height: 18),
        PrimaryButton(label: 'Book Package', onPressed: () {}),
      ]),
    );
  }
}
