import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/lab_report.dart';
import '../../../services/shared_data_repository.dart';

class ReportBuilderScreen extends ConsumerStatefulWidget {
  const ReportBuilderScreen({super.key});

  @override
  ConsumerState<ReportBuilderScreen> createState() => _ReportBuilderScreenState();
}

class _ReportBuilderScreenState extends ConsumerState<ReportBuilderScreen> {
  @override
  Widget build(BuildContext context) {
    final sharedData = ref.watch(sharedDataProvider);
    final reports = sharedData.reports;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Report Builder (Drafts & Submissions)'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notice Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF93C5FD)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, color: Color(0xFF1D4ED8)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Staff Permissions Notice: Receptionists and Lab Technicians can create, edit, save draft reports, and submit them for verification. Final Report Approval is restricted to Admin / Lab Owner.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text('Active Diagnostic Reports', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reports.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              report.reportId,
                              style: AppTextStyles.headline3.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusBg(report.status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                report.status.displayName,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _statusText(report.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(report.testName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        Text('Patient: ${report.patientName} (${report.patientAgeGender})', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        Text('Pathologist: ${report.doctorPathologistName}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                context.push('/pdf-report?reportId=${report.reportId}');
                              },
                              icon: const Icon(Icons.visibility, size: 16),
                              label: const Text('Preview PDF'),
                            ),
                            const SizedBox(width: 10),
                            if (report.status == ReportStatus.draft || report.status == ReportStatus.rejected)
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    ref.read(sharedDataProvider.notifier).submitReportDraft(
                                          report.copyWith(status: ReportStatus.readyForVerification),
                                        );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Report ${report.reportId} submitted for Admin Verification!')),
                                    );
                                  },
                                  icon: const Icon(Icons.send, size: 16),
                                  label: const Text('Submit for Verification'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusBg(ReportStatus status) {
    switch (status) {
      case ReportStatus.draft:
        return const Color(0xFFFFF8E1);
      case ReportStatus.readyForVerification:
        return const Color(0xFFE3F2FD);
      case ReportStatus.approved:
      case ReportStatus.finalized:
        return const Color(0xFFE8F5E9);
      case ReportStatus.rejected:
        return const Color(0xFFFFEBEE);
    }
  }

  Color _statusText(ReportStatus status) {
    switch (status) {
      case ReportStatus.draft:
        return const Color(0xFFF57F17);
      case ReportStatus.readyForVerification:
        return const Color(0xFF1565C0);
      case ReportStatus.approved:
      case ReportStatus.finalized:
        return const Color(0xFF2E7D32);
      case ReportStatus.rejected:
        return const Color(0xFFD32F2F);
    }
  }
}
