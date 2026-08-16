import 'package:flutter/material.dart';
import '../theme/text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const SectionHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.headline3.copyWith(fontSize: 24, letterSpacing: 0.2)),
        const SizedBox(height: 6),
        Text(subtitle, style: AppTextStyles.subtitle),
      ],
    );
  }
}
