import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendReset() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).sendPasswordReset(emailOrMobile: emailController.text.trim());
      if (mounted) {
        context.go('/reset-password');
      }
    } catch (e) {
      if (mounted) {
        final rawMsg = e.toString().replaceFirst('Exception: ', '').trim();
        final msg = rawMsg.isNotEmpty && !rawMsg.toLowerCase().contains('internal server error')
            ? rawMsg
            : 'Unable to send reset link. Please try again later.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
      appBar: AppBar(title: const Text('Forgot Password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recover your account', style: AppTextStyles.headline3),
              const SizedBox(height: 10),
              Text('Enter your registered email or mobile number to continue.', style: AppTextStyles.subtitle),
              const SizedBox(height: 24),
              AppTextField(label: 'Email or mobile', hint: 'support@astha.com or +919876543210', controller: emailController, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 24),
              PrimaryButton(label: 'Send reset link', onPressed: _sendReset, isLoading: _isLoading),
            ],
          ),
        ),
      ),
    );
  }
}
