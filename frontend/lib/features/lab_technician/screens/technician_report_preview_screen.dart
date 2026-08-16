import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/test_result_model.dart';
import '../providers/lab_technician_provider.dart';
import '../widgets/lab_tech_scaffold.dart';
import '../widgets/sample_status_chip.dart';

class TechnicianReportPreviewScreen extends ConsumerWidget {
  final String? sampleId;

  const TechnicianReportPreviewScreen({super.key, this.sampleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final techState = ref.watch(labTechnicianProvider);
    final targetSampleId = sampleId ?? 'SMP10024';

    final resultRecord = techState.results.firstWhere(
      (r) => r.sampleId == targetSampleId,
      orElse: () {
        final test = techState.assignedTests.firstWhere(
          (t) => t.sampleId == targetSampleId,
          orElse: () => techState.assignedTests.first,
        );
        final defaultParams = ref.read(labTechnicianProvider.notifier).getTemplateForTest(test.testName);
        return DynamicTestResultRecord(
          resultId: 'R-${test.sampleId}',
          sampleId: test.sampleId,
          patientId: test.patientId,
          patientName: test.patientName,
          patientAgeGender: test.patientAgeGender,
          testName: test.testName,
          sampleType: test.sampleType,
          parameters: defaultParams,
          remarks: 'All parameters are within normal range.',
          technicianName: techState.profile.name,
          testDate: '13 May 2025 02:15 PM',
        );
      },
    );

    return LabTechScaffold(
      title: 'Report Preview',
      currentRoute: '/lab-tech/report-preview',
      actions: [
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Preparing report document for printing...')),
            );
          },
          icon: const Icon(Icons.print_outlined, size: 16),
          label: const Text('Print'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sharing report preview link...')),
            );
          },
          icon: const Icon(Icons.share_outlined, size: 16),
          label: const Text('Share'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          ),
        ),
        const SizedBox(width: 16),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            // A4-style Report Paper Card
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── LABORATORY HEADER & LOGO ────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.biotech, color: Color(0xFF2563EB), size: 36),
                          ),
                          const SizedBox(width: 16),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ASTHA DIAGNOSTIC LABORATORY',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '123, Health Care Street, Roorkee, Uttarakhand',
                                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                              Text(
                                'Phone: 01234-567890 | Email: info@asthadiagnostic.com',
                                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(thickness: 1.5, color: Color(0xFFE2E8F0)),
                  ),

                  // ── PATIENT & SAMPLE DETAILS GRID ───────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _ReportMetaRow(label: 'Patient Name', value: resultRecord.patientName)),
                            Expanded(child: _ReportMetaRow(label: 'Sample ID', value: resultRecord.sampleId, isBold: true)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: _ReportMetaRow(label: 'Patient ID', value: resultRecord.patientId)),
                            Expanded(child: _ReportMetaRow(label: 'Sample Type', value: resultRecord.sampleType)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: _ReportMetaRow(label: 'Age / Gender', value: resultRecord.patientAgeGender)),
                            Expanded(child: _ReportMetaRow(label: 'Collection Date', value: '13 May 2025')),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: _ReportMetaRow(label: 'Ref. By Doctor', value: resultRecord.doctorName)),
                            Expanded(child: _ReportMetaRow(label: 'Report Date', value: resultRecord.testDate)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── TEST NAME TITLE ─────────────────────────────────────────
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        resultRecord.testName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── RESULTS TABLE ───────────────────────────────────────────
                  Table(
                    border: TableBorder.all(color: const Color(0xFFE2E8F0), width: 1),
                    columnWidths: const {
                      0: FlexColumnWidth(2.5),
                      1: FlexColumnWidth(1.2),
                      2: FlexColumnWidth(1.2),
                      3: FlexColumnWidth(2.0),
                      4: FlexColumnWidth(1.2),
                    },
                    children: [
                      // Header Row
                      TableRow(
                        decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
                        children: [
                          _tableHeaderCell('Parameter'),
                          _tableHeaderCell('Result'),
                          _tableHeaderCell('Unit'),
                          _tableHeaderCell('Reference Range'),
                          _tableHeaderCell('Status'),
                        ],
                      ),
                      // Data Rows
                      ...resultRecord.parameters.map((param) {
                        return TableRow(
                          children: [
                            _tableBodyCell(param.parameterName, isBold: true),
                            _tableBodyCell(param.resultValue),
                            _tableBodyCell(param.unit),
                            _tableBodyCell(param.referenceRange),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SampleStatusChip.fromResultFlag(param.status),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── REMARKS ────────────────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Remarks : ',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A)),
                      ),
                      Expanded(
                        child: Text(
                          resultRecord.remarks.isEmpty ? 'All parameters are within normal range.' : resultRecord.remarks,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // ── TECHNICIAN SIGNATURE & STAMP FOOTER ────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Technician Name:', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          const SizedBox(height: 4),
                          Text(
                            resultRecord.technicianName,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          const Text('(Lab Technician)', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          const SizedBox(height: 12),
                          // Signature placeholder graphic line
                          Container(width: 140, height: 1, color: const Color(0xFF94A3B8)),
                        ],
                      ),
                      // Astha Diagnostic Lab Stamp Circle Placeholder
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF2563EB), width: 2),
                        ),
                        child: const Center(
                          child: Text(
                            'ASTHA\nSTAMP',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // System generated note
                  const Center(
                    child: Text(
                      'This is system generated report.',
                      style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic),
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

  static Widget _tableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A)),
      ),
    );
  }

  static Widget _tableBodyCell(String text, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          color: const Color(0xFF334155),
        ),
      ),
    );
  }
}

class _ReportMetaRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _ReportMetaRow({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label :',
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isBold ? const Color(0xFF2563EB) : const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }
}
