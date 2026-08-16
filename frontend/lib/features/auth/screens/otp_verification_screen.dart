import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final otpController = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('OTP Verification')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enter the verification code', style: AppTextStyles.headline3),
              const SizedBox(height: 10),
              Text('We sent a 6-digit code to your registered email.', style: AppTextStyles.subtitle),
              const SizedBox(height: 24),
              AppTextField(label: 'OTP code', hint: '123456', controller: otpController, keyboardType: TextInputType.number),
              const SizedBox(height: 24),
              PrimaryButton(label: 'Verify & continue', onPressed: () => context.go('/login')),
            ],
          ),
        ),
      ),
    );
  }
}
