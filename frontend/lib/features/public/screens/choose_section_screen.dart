import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';

class ChooseSectionScreen extends StatelessWidget {
  const ChooseSectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Choose Section',
          style: AppTextStyles.headline3.copyWith(fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Main text
              Text(
                'How can we help you?',
                style: AppTextStyles.headline2.copyWith(
                  fontSize: 26,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please select an option to continue',
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // CARD 1 — BOOK A TEST
              _ChooseCard(
                title: 'Book a Test',
                description:
                    'Book lab tests, collect samples and get accurate reports at your convenience.',
                buttonText: 'Continue',
                backgroundColor: const Color(0xFFEEF5FF),
                titleColor: const Color(0xFF1565C0),
                buttonColor: const Color(0xFF1565C0),
                imagePath: 'assets/images/test_tubes_rack.png',
                onTap: () => context.push('/public/book-test'),
              ),

              const SizedBox(height: 24),

              // CARD 2 — DOCTOR APPOINTMENT
              _ChooseCard(
                title: 'Doctor Appointment',
                description:
                    'Consult with experienced doctors and get the best medical guidance.',
                buttonText: 'Continue',
                backgroundColor: const Color(0xFFE8F7F5),
                titleColor: const Color(0xFF00796B),
                buttonColor: const Color(0xFF00796B),
                imagePath: 'assets/images/stethoscope_icon.png',
                onTap: () => context.push('/public/book-appointment'),
              ),

              const SizedBox(height: 36),

              // Security banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE0F2F1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: Color(0xFF00796B),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Your data is 100% secure and private with us.',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
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
      ),
    );
  }
}

class _ChooseCard extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final Color backgroundColor;
  final Color titleColor;
  final Color buttonColor;
  final String imagePath;
  final VoidCallback onTap;

  const _ChooseCard({
    required this.title,
    required this.description,
    required this.buttonText,
    required this.backgroundColor,
    required this.titleColor,
    required this.buttonColor,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: buttonColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Text content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.52,
                child: Text(
                  title,
                  style: AppTextStyles.headline2.copyWith(
                    color: titleColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.52,
                child: Text(
                  description,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onTap,
                icon: Text(
                  '$buttonText  →',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                label: const SizedBox.shrink(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                ),
              ),
            ],
          ),

          // Illustration on right
          Positioned(
            right: 0,
            bottom: 0,
            top: 0,
            child: SizedBox(
              width: 100,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.medical_services,
                  size: 64,
                  color: titleColor.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
