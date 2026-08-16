import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/assigned_test_model.dart';
import '../providers/lab_technician_provider.dart';
import '../widgets/assigned_test_card.dart';
import '../widgets/lab_tech_scaffold.dart';
import '../widgets/sample_status_chip.dart';

class AssignedTestsScreen extends ConsumerWidget {
  const AssignedTestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final techState = ref.watch(labTechnicianProvider);
    final techNotifier = ref.read(labTechnicianProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final filteredTests = techState.filteredTests;

    return LabTechScaffold(
      title: 'Assigned Tests',
      currentRoute: '/lab-tech/assigned-tests',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── SEARCH & FILTER CONTROLS BAR ─────────────────────────────────
            Container(
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
              child: Wrap(
                spacing: 14,
                runSpacing: 14,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Search Field
                  SizedBox(
                    width: isDesktop ? 320 : double.infinity,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search by Patient / Sample ID / Test',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          ),
                        ),
                      ),
                      onChanged: (val) => techNotifier.setSearchQuery(val),
                    ),
                  ),

                  // Status Filter Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: techState.selectedStatusFilter,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'All Status', child: Text('All Status')),
                          DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                          DropdownMenuItem(value: 'Sample Collected', child: Text('Sample Collected')),
                          DropdownMenuItem(value: 'In Progress', child: Text('In Progress')),
                          DropdownMenuItem(value: 'Result Entered', child: Text('Result Entered')),
                          DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                        ],
                        onChanged: (val) {
                          if (val != null) techNotifier.setStatusFilter(val);
                        },
                      ),
                    ),
                  ),

                  // Test Type Filter Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: techState.selectedTestFilter,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'All Tests', child: Text('All Tests')),
                          DropdownMenuItem(value: 'CBC', child: Text('CBC (Blood Count)')),
                          DropdownMenuItem(value: 'Lipid Profile', child: Text('Lipid Profile')),
                          DropdownMenuItem(value: 'Blood Glucose', child: Text('Blood Glucose')),
                          DropdownMenuItem(value: 'Thyroid Profile', child: Text('Thyroid Profile')),
                          DropdownMenuItem(value: 'Liver Function Test', child: Text('Liver Function Test')),
                        ],
                        onChanged: (val) {
                          if (val != null) techNotifier.setTestFilter(val);
                        },
                      ),
                    ),
                  ),

                  // Filter Action Button
                  OutlinedButton.icon(
                    onPressed: () {
                      techNotifier.setSearchQuery('');
                      techNotifier.setStatusFilter('All Status');
                      techNotifier.setTestFilter('All Tests');
                    },
                    icon: const Icon(Icons.filter_list, size: 16),
                    label: const Text('Reset Filter'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── ASSIGNED TESTS TABLE / CARD LIST ─────────────────────────────
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
                  dataRowMaxHeight: 70,
                  horizontalMargin: 20,
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('Patient', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Test Details', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Sample ID', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Priority', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: filteredTests.map((test) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                test.patientName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                '${test.patientId} | ${test.patientAgeGender.split(' ').take(2).join(' ')}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                test.testName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: isDark ? Colors.white70 : const Color(0xFF334155),
                                ),
                              ),
                              Text(
                                test.category,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Text(
                            test.sampleId,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                        DataCell(SampleStatusChip.fromPriority(test.priority)),
                        DataCell(SampleStatusChip.fromAssignedStatus(test.status)),
                        DataCell(
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  context.go('/lab-tech/test-processing?sampleId=${test.sampleId}');
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  visualDensity: VisualDensity.compact,
                                ),
                                child: const Text('View Details', style: TextStyle(fontSize: 12)),
                              ),
                              const SizedBox(width: 6),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, size: 18),
                                onSelected: (action) {
                                  if (action == 'start') {
                                    techNotifier.updateTestStatus(test.sampleId, AssignedTestStatus.inProgress);
                                    context.go('/lab-tech/test-processing?sampleId=${test.sampleId}');
                                  } else if (action == 'entry') {
                                    context.go('/lab-tech/result-entry?sampleId=${test.sampleId}');
                                  } else if (action == 'preview') {
                                    context.go('/lab-tech/report-preview?sampleId=${test.sampleId}');
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(value: 'start', child: Text('Start Test')),
                                  PopupMenuItem(value: 'entry', child: Text('Enter Result')),
                                  PopupMenuItem(value: 'preview', child: Text('View Report Preview')),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredTests.length,
                itemBuilder: (context, index) {
                  return AssignedTestCard(test: filteredTests[index]);
                },
              ),
          ],
        ),
      ),
    );
  }
}
