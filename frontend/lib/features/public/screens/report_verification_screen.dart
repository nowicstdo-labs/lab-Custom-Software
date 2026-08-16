import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../services/shared_data_repository.dart';

class ReportVerificationScreen extends ConsumerWidget {
  final String? reportId;

  const ReportVerificationScreen({super.key, this.reportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedData = ref.watch(sharedDataProvider);
    final report = sharedData.reports.firstWhere(
      (r) => r.reportId == reportId,
      orElse: () => sharedData.reports.first,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Report Verification'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Verification Shield Animation Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified_user_rounded,
                      color: Color(0xFF2E7D32),
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 18),

                  Text(
                    'ASTHA DIAGNOSTIC',
                    style: AppTextStyles.headline3.copyWith(
                      fontSize: 16,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '✓ Authentic Report Verified',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 20),

                  _VerifyItem(label: 'Report ID', value: report.reportId, isBold: true),
                  _VerifyItem(label: 'Test Name', value: report.testName, isBold: true),
                  _VerifyItem(label: 'Report Date', value: report.reportDate),
                  _VerifyItem(label: 'Pathologist', value: report.doctorPathologistName),
                  _VerifyItem(label: 'Status', value: report.status.name.toUpperCase()),
                  _VerifyItem(
                    label: 'Security Token',
                    value: report.qrToken.length > 20
                        ? '${report.qrToken.substring(0, 20)}...'
                        : report.qrToken,
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.push('/pdf-report?reportId=${report.reportId}');
                      },
                      icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                      label: const Text('View Full A4 Report PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VerifyItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _VerifyItem({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
