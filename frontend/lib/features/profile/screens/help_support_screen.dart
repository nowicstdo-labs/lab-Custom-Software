import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const List<Map<String, String>> _faqs = [
    {
      'question': 'How do I book a lab test?',
      'answer': 'Tap "Book a Test" on the Home screen, select your required diagnostic tests, enter patient details, choose your preferred appointment date and time slot, and confirm your booking.',
    },
    {
      'question': 'How will I receive my lab test reports?',
      'answer': 'Once your test report is processed and verified by our pathologists, it will automatically appear under "My Tests" and "Reports" on your dashboard for instant viewing and PDF download.',
    },
    {
      'question': 'What is the maximum capacity for time slots?',
      'answer': 'Each time slot has a maximum capacity of 10 patients to ensure zero waiting time and personalized attention during sample collection.',
    },
    {
      'question': 'Can I reschedule or cancel an appointment?',
      'answer': 'Yes, you can view and manage your upcoming bookings from "My Tests" or "Profile → My Appointments" at any time.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Help & Support',
          style: AppTextStyles.headline3.copyWith(
            fontSize: 18,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Support Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00796B), Color(0xFF004D40)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Need Assistance?',
                              style: AppTextStyles.headline3.copyWith(color: Colors.white, fontSize: 18),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Our patient care team is available 24/7',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Calling helpline +91 1800 123 4567...')),
                            );
                          },
                          icon: const Icon(Icons.phone, size: 16, color: Color(0xFF00796B)),
                          label: const Text('Call Us', style: TextStyle(color: Color(0xFF00796B), fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Opening WhatsApp support...')),
                            );
                          },
                          icon: const Icon(Icons.chat, size: 16, color: Colors.white),
                          label: const Text('WhatsApp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text('Frequently Asked Questions', style: AppTextStyles.headline3.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            ..._faqs.map((faq) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ExpansionTile(
                    title: Text(
                      faq['question']!,
                      style: AppTextStyles.headline3.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(
                          faq['answer']!,
                          style: AppTextStyles.body.copyWith(fontSize: 13, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
