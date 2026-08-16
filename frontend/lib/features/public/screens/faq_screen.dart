import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQ')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Frequently asked questions', style: AppTextStyles.headline2),
          const SizedBox(height: 14),
          Text('Answers for enterprise healthcare and diagnostic workflows.', style: AppTextStyles.subtitle),
          const SizedBox(height: 26),
          const _FaqCard(question: 'Can I manage multiple lab branches?', answer: 'Yes. The architecture supports multi-branch roles, inventory and analytics across facilities.'),
          const SizedBox(height: 16),
          const _FaqCard(question: 'Is role-based access supported?', answer: 'Yes. Each user role sees only the modules and menus assigned to their permissions.'),
          const SizedBox(height: 16),
          const _FaqCard(question: 'Can I switch between light and dark mode?', answer: 'The app supports theme-aware design with a polished Material 3 experience.'),
        ]),
      ),
    );
  }
}

class _FaqCard extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqCard({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 12))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(question, style: AppTextStyles.headline3.copyWith(fontSize: 18)),
        const SizedBox(height: 10),
        Text(answer, style: AppTextStyles.body.copyWith(height: 1.6)),
      ]),
    );
  }
}
