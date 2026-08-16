import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/test_result.dart';
import '../../../services/shared_data_repository.dart';

class A4PdfReportScreen extends ConsumerWidget {
  final String? reportId;

  const A4PdfReportScreen({super.key, this.reportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedData = ref.watch(sharedDataProvider);
    final report = sharedData.reports.firstWhere(
      (r) => r.reportId == reportId,
      orElse: () => sharedData.reports.first,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF525659), // Standard PDF viewer background
      appBar: AppBar(
        title: Text(
          'Diagnostic Report — ${report.reportId}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            tooltip: 'Download PDF',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Downloading report ${report.reportId}.pdf...'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.print_rounded, color: Colors.white),
            tooltip: 'Print Report',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sending document to printer...')),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            onSelected: (val) {
              if (val == 'whatsapp') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('WhatsApp API Service (Ready for Backend Integration): Link sent to patient phone.'),
                  ),
                );
              } else if (val == 'email') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Email Service (Ready for Backend Integration): PDF report sent via email.'),
                  ),
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'whatsapp', child: Text('Send via WhatsApp (Mock)')),
              PopupMenuItem(value: 'email', child: Text('Send via Email (Mock)')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800), // A4 page aspect ratio width
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── HEADER / BRANDING ──────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.biotech, color: AppColors.primary, size: 36),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ASTHA DIAGNOSTIC',
                              style: AppTextStyles.headline1.copyWith(
                                fontSize: 24,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const Text(
                              'CARE • ACCURACY • TRUST',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                                letterSpacing: 2,
                              ),
                            ),
                            const Text(
                              'NABL Accredited Diagnostic Center • License #ASTH-98214',
                              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF81C784)),
                          ),
                          child: const Text(
                            '✓ AUTHENTIC REPORT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Report ID: ${report.reportId}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Date: ${report.reportDate}',
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 32, thickness: 1.5, color: Color(0xFFE2E8F0)),

                // ── PATIENT & TEST INFORMATION BOX ──────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _PdfDetailRow(label: 'Patient Name', value: report.patientName, isBold: true),
                            _PdfDetailRow(label: 'Patient ID', value: report.patientId),
                            _PdfDetailRow(label: 'Age / Gender', value: report.patientAgeGender),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 60, color: const Color(0xFFCBD5E1)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _PdfDetailRow(label: 'Test Name', value: report.testName, isBold: true),
                            _PdfDetailRow(label: 'Sample Type', value: report.sampleType),
                            _PdfDetailRow(label: 'Collection Date', value: report.collectionDate),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── TEST RESULTS TABLE ──────────────────────────────────────────
                Text(
                  'LABORATORY TEST RESULTS',
                  style: AppTextStyles.headline3.copyWith(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),

                Table(
                  border: TableBorder.all(color: const Color(0xFFE2E8F0), width: 1),
                  columnWidths: const {
                    0: FlexColumnWidth(2.5),
                    1: FlexColumnWidth(1.2),
                    2: FlexColumnWidth(1.0),
                    3: FlexColumnWidth(1.8),
                    4: FlexColumnWidth(1.0),
                  },
                  children: [
                    // Table Header
                    TableRow(
                      decoration: const BoxDecoration(color: Color(0xFF1E293B)),
                      children: const [
                        _TableHeaderCell(text: 'Parameter Name'),
                        _TableHeaderCell(text: 'Result'),
                        _TableHeaderCell(text: 'Unit'),
                        _TableHeaderCell(text: 'Reference Range'),
                        _TableHeaderCell(text: 'Flag'),
                      ],
                    ),
                    // Result Rows
                    ...report.parameters.map((param) {
                      final isAbnormal = param.flag != ParameterFlag.normal;
                      return TableRow(
                        decoration: BoxDecoration(
                          color: isAbnormal ? const Color(0xFFFFF1F2) : Colors.white,
                        ),
                        children: [
                          _TableCell(text: param.parameterName, isBold: true),
                          _TableCell(
                            text: param.resultValue,
                            isBold: isAbnormal,
                            textColor: isAbnormal ? Colors.red.shade700 : AppColors.textPrimary,
                          ),
                          _TableCell(text: param.unit),
                          _TableCell(text: param.referenceRange),
                          _TableCell(
                            text: param.flag.displayName.toUpperCase(),
                            isBold: true,
                            textColor: isAbnormal ? Colors.red.shade700 : const Color(0xFF16A34A),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 32),

                // ── REMARKS SECTION ─────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Remarks: Results correlate clinically. Repeat evaluation recommended if symptoms persist.',
                          style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // ── SIGNATURES & QR VERIFICATION FOOTER ─────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // QR Code Verification
                    GestureDetector(
                      onTap: () {
                        context.push('/public/report-verification?reportId=${report.reportId}');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.qr_code_2, color: Colors.white, size: 50),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Scan QR Code',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                                const Text(
                                  'To verify report authenticity',
                                  style: TextStyle(fontSize: 9, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Token: ${report.qrToken.substring(0, 16)}...',
                                  style: const TextStyle(fontSize: 8, color: AppColors.primary, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Doctor Pathologist Signature Box
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 140,
                          height: 40,
                          alignment: Alignment.center,
                          child: Text(
                            report.doctorPathologistName.split(',').first,
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                        ),
                        Container(width: 160, height: 1, color: const Color(0xFF94A3B8)),
                        const SizedBox(height: 4),
                        Text(
                          report.doctorPathologistName,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          report.doctorQualifications,
                          style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                const Divider(color: Color(0xFFE2E8F0)),
                const Center(
                  child: Text(
                    'Astha Diagnostic • 104 Health Complex, MG Road • Helpdesk: +91 98765 00000 • www.asthadiagnostic.com',
                    style: TextStyle(fontSize: 9, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PdfDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _PdfDetailRow({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
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

class _TableHeaderCell extends StatelessWidget {
  final String text;

  const _TableHeaderCell({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isBold;
  final Color textColor;

  const _TableCell({
    required this.text,
    this.isBold = false,
    this.textColor = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: textColor,
        ),
      ),
    );
  }
}
