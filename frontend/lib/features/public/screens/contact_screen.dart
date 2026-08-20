import 'package:flutter/material.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('We are here to help', style: AppTextStyles.headline2),
          const SizedBox(height: 10),
          Text('Reach out for onboarding, support, or custom enterprise integrations.', style: AppTextStyles.subtitle),
          const SizedBox(height: 24),
          AppTextField(label: 'Full name', hint: 'Enter your name', controller: _nameController),
          const SizedBox(height: 18),
          AppTextField(label: 'Email address', hint: 'Enter your email', controller: _emailController, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 18),
          Text('Message', style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          TextField(
            controller: _messageController,
            minLines: 4,
            maxLines: 6,
            decoration: const InputDecoration(hintText: 'How can we help you?'),
          ),
          const SizedBox(height: 24),
          PrimaryButton(label: 'Send message', onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Support request sent successfully.')));
          }),
        ]),
      ),
    );
  }
}

