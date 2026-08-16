import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/assigned_test_model.dart';
import '../providers/lab_technician_provider.dart';
import '../widgets/lab_tech_scaffold.dart';
import '../widgets/sample_status_chip.dart';

class CompletedTestsScreen extends ConsumerWidget {
  const CompletedTestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final techState = ref.watch(labTechnicianProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    final completedTests = techState.assignedTests.where(
      (t) => t.status == AssignedTestStatus.completed || t.status == AssignedTestStatus.resultEntered,
    ).toList();

    return LabTechScaffold(
      title: 'Completed Tests',
      currentRoute: '/lab-tech/completed',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Completed & Submitted Tests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'View testing records whose results have been entered and submitted for verification.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),

            if (isDesktop)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                  ),
                ),
                child: DataTable(
                  headingRowHeight: 52,
                  dataRowMaxHeight: 68,
                  horizontalMargin: 20,
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('Patient', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Test Name', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Sample ID', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Completed Date', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Technician', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: completedTests.map((test) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(test.patientName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                              Text('PID: ${test.patientId}', style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                            ],
                          ),
                        ),
                        DataCell(Text(test.testName, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: isDark ? Colors.white70 : const Color(0xFF334155)))),
                        DataCell(Text(test.sampleId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2563EB)))),
                        DataCell(Text(test.appointmentDate, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : const Color(0xFF475569)))),
                        DataCell(Text(test.assignedTechnician, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : const Color(0xFF475569)))),
                        DataCell(SampleStatusChip.fromAssignedStatus(test.status)),
                        DataCell(
                          ElevatedButton.icon(
                            onPressed: () {
                              context.go('/lab-tech/report-preview?sampleId=${test.sampleId}');
                            },
                            icon: const Icon(Icons.description, size: 14),
                            label: const Text('View Report'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: completedTests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final test = completedTests[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(test.patientName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                            SampleStatusChip.fromAssignedStatus(test.status),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('${test.testName} • ${test.sampleId}', style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Date: ${test.appointmentDate}', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                            ElevatedButton(
                              onPressed: () {
                                context.go('/lab-tech/report-preview?sampleId=${test.sampleId}');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                visualDensity: VisualDensity.compact,
                              ),
                              child: const Text('View Report'),
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
    );
  }
}
