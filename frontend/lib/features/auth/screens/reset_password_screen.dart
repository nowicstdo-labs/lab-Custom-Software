import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final emailOrPhoneController = TextEditingController();
  final otpController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final destination = ref.read(authProvider).otpDestination;
    if (destination != null && destination.isNotEmpty) {
      emailOrPhoneController.text = destination;
    }
  }

  Future<void> _resetPassword() async {
    final emailOrPhone = emailOrPhoneController.text.trim();
    final otp = otpController.text.trim();
    final password = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    if (emailOrPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your email or phone number.')));
      return;
    }

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter the OTP code.')));
      return;
    }

    if (password != confirm || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords must match.')));
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must be at least 6 characters.')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await ref.read(authProvider.notifier).resetPasswordWithOtp(
            emailOrPhone: emailOrPhone,
            otp: otp,
            password: password,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Set a new secure password', style: AppTextStyles.headline2),
                const SizedBox(height: 10),
                Text('Enter the OTP received and create your new password.', style: AppTextStyles.subtitle),
                const SizedBox(height: 24),
                AppTextField(label: 'Email or Mobile', hint: 'support@astha.com or +919876543210', controller: emailOrPhoneController),
                const SizedBox(height: 18),
                AppTextField(label: 'OTP Code', hint: 'Enter 6-digit OTP', controller: otpController, keyboardType: TextInputType.number),
                const SizedBox(height: 18),
                AppTextField(label: 'New password', hint: 'Enter new password', controller: passwordController, obscureText: true),
                const SizedBox(height: 18),
                AppTextField(label: 'Confirm password', hint: 'Re-enter password', controller: confirmController, obscureText: true),
                const SizedBox(height: 24),
                PrimaryButton(label: 'Reset password', onPressed: _resetPassword, isLoading: _isLoading),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
