import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../core/widgets/section_header.dart';
import '../../dashboard/providers/admin_cms_provider.dart';

class PublicHomeScreen extends ConsumerWidget {
  const PublicHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cms = ref.watch(adminCmsProvider);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(cms.labName),
        actions: [
          TextButton(onPressed: () => context.go('/public/about'), child: const Text('About')),
          TextButton(onPressed: () => context.go('/public/packages'), child: const Text('Packages')),
          TextButton(onPressed: () => context.go('/public/tests'), child: const Text('Tests')),
          TextButton(onPressed: () => context.go('/login'), child: const Text('Login')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.18), blurRadius: 32, offset: const Offset(0, 14)),
                ],
              ),
              child: width > 900
                  ? Row(
                      children: [
                        Expanded(child: _HeroSection(cms: cms)),
                        const SizedBox(width: 32),
                        Expanded(child: _HeroIllustration()),
                      ],
                    )
                  : Column(children: [ _HeroSection(cms: cms), const SizedBox(height: 24), _HeroIllustration() ]),
            ),
            const SizedBox(height: 28),

            if (cms.showPromoBanner) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFE082)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_offer, color: Color(0xFFF57F17)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        cms.promoTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF57F17)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],

            const SectionHeader(title: 'Trusted by clinics and labs', subtitle: 'Built for premium healthcare operations with a modern, secure UI.'),
            const SizedBox(height: 18),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: const [
                _FeatureCard(icon: Icons.medical_services, title: 'Smart booking', subtitle: 'Schedule tests, appointments and collections.'),
                _FeatureCard(icon: Icons.analytics, title: 'Analytics dashboard', subtitle: 'Revenue, queue and lab insights in one view.'),
                _FeatureCard(icon: Icons.shield, title: 'Secure access', subtitle: 'Role-based navigation with permissions.'),
              ],
            ),
            const SizedBox(height: 28),
            _ActionBanner(onBookTest: () => context.go('/public/book-test'), onBookAppointment: () => context.go('/public/book-appointment')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Launching ${cms.labName} support...')));
        },
        icon: const Icon(Icons.chat),
        label: const Text('WhatsApp'),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final CmsState cms;

  const _HeroSection({required this.cms});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(cms.heroTitle, style: AppTextStyles.headline1.copyWith(color: Colors.white, fontSize: 36)),
        const SizedBox(height: 16),
        Text(cms.heroSubtitle, style: AppTextStyles.subtitle.copyWith(color: Colors.white70, fontSize: 18)),
        const SizedBox(height: 24),
        Row(children: [
          PrimaryButton(label: cms.heroButtonText, onPressed: () => context.go('/public/book-test')),
          const SizedBox(width: 16),
          SecondaryButton(label: 'View packages', onPressed: () => context.go('/public/packages')),
        ]),
      ],
    );
  }
}

class _HeroIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.2,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Colors.white, Color(0xFFE7F3FF)]),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(child: Icon(Icons.health_and_safety, size: 140, color: AppColors.primary.withValues(alpha: 0.85))),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureCard({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: 0.12), child: Icon(icon, color: AppColors.primary)),
          const SizedBox(height: 14),
          Text(title, style: AppTextStyles.headline3.copyWith(fontSize: 18)),
          const SizedBox(height: 8),
          Text(subtitle, style: AppTextStyles.subtitle.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}

class _ActionBanner extends StatelessWidget {
  final VoidCallback onBookTest;
  final VoidCallback onBookAppointment;

  const _ActionBanner({required this.onBookTest, required this.onBookAppointment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ready to streamline your diagnostics?', style: AppTextStyles.headline2.copyWith(color: Colors.white, fontSize: 22)),
                const SizedBox(height: 8),
                Text('Book blood tests or doctor consultations online in seconds.', style: AppTextStyles.subtitle.copyWith(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onBookTest,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Book Test'),
          ),
        ],
      ),
    );
  }
}
