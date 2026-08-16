import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/lab_report.dart';
import '../../../models/test_result.dart';
import '../../../services/shared_data_repository.dart';
import '../../../services/api_service.dart';

class ReportApprovalScreen extends ConsumerStatefulWidget {
  const ReportApprovalScreen({super.key});

  @override
  ConsumerState<ReportApprovalScreen> createState() => _ReportApprovalScreenState();
}

class _ReportApprovalScreenState extends ConsumerState<ReportApprovalScreen> {
  final _rejectionReasonController = TextEditingController();

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  void _showRejectDialog(BuildContext context, LabReport report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Reject Report: ${report.reportId}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please provide a clear reason for rejecting this laboratory report. The technician will be notified to revise the draft.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _rejectionReasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'E.g., Parameter Hemoglobin value out of expected biological bounds.',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final reason = _rejectionReasonController.text.trim();
              if (reason.isEmpty) return;
              ref.read(sharedDataProvider.notifier).rejectReport(report.reportId, reason);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Report ${report.reportId} rejected.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sharedData = ref.watch(sharedDataProvider);
    final reports = sharedData.reports;

    final pendingReports = reports.where((r) => r.status == ReportStatus.readyForVerification || r.status == ReportStatus.draft).toList();
    final approvedReports = reports.where((r) => r.status == ReportStatus.approved || r.status == ReportStatus.finalized).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Report Verification & Approval'),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => context.pop(),
          ),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Pending Verification'),
              Tab(text: 'Approved Reports'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Pending Queue
            pendingReports.isEmpty
                ? const Center(child: Text('No reports currently pending verification.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: pendingReports.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final report = pendingReports[index];
                      return _AdminReportApprovalCard(
                        report: report,
                        onApprove: () async {
                          try {
                            await ApiService.post('/reports/${report.reportId}/approve', {
                              'approved': true,
                            });
                          } catch (_) {}
                          ref.read(sharedDataProvider.notifier).approveReport(report.reportId, 'Admin / Lab Owner');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Report ${report.reportId} APPROVED! Patient notified.'),
                                backgroundColor: const Color(0xFF2E7D32),
                              ),
                            );
                          }
                        },
                        onReject: () => _showRejectDialog(context, report),
                      );
                    },
                  ),

            // Tab 2: Approved History
            approvedReports.isEmpty
                ? const Center(child: Text('No approved reports.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: approvedReports.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final report = approvedReports[index];
                      return _AdminReportApprovalCard(
                        report: report,
                        isApprovedView: true,
                        onApprove: null,
                        onReject: null,
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

class _AdminReportApprovalCard extends StatelessWidget {
  final LabReport report;
  final bool isApprovedView;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const _AdminReportApprovalCard({
    required this.report,
    this.isApprovedView = false,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
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
                  color: isApprovedView ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  report.status.displayName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isApprovedView ? const Color(0xFF2E7D32) : const Color(0xFFF57F17),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(report.testName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          Text('Patient: ${report.patientName} (${report.patientAgeGender})', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text('Sample ID: ${report.sampleId} • Date: ${report.reportDate}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 12),

          // Parameter Quick Snapshot
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: report.parameters.map((p) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(p.parameterName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      Text('${p.resultValue} ${p.unit} (${p.flag.displayName})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  context.push('/pdf-report?reportId=${report.reportId}');
                },
                icon: const Icon(Icons.picture_as_pdf, size: 16),
                label: const Text('Preview PDF'),
              ),
              const SizedBox(width: 10),
              if (!isApprovedView) ...[
                OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Reject'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check_circle, size: 16),
                    label: const Text('Approve Final Report'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
