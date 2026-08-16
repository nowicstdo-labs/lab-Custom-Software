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
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    if (passwordController.text != confirmController.text || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords must match.')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).resetPassword(resetToken: 'reset-token', password: passwordController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated successfully.')));
        context.go('/login');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to reset password.')));
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
                Text('Create a password to unlock your Astha Diagnostic account.', style: AppTextStyles.subtitle),
                const SizedBox(height: 24),
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
