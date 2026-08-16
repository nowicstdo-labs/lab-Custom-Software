import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/staggered_entrance_list.dart';
import '../providers/lab_technician_provider.dart';
import '../widgets/lab_tech_scaffold.dart';
import '../widgets/sample_status_chip.dart';
import '../widgets/technician_stat_card.dart';

class LabTechnicianDashboardScreen extends ConsumerWidget {
  const LabTechnicianDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final techState = ref.watch(labTechnicianProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return LabTechScaffold(
      title: 'Dashboard',
      currentRoute: '/lab-tech',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── TOP STATS CARDS WITH STAGGERED ENTRANCE ──────────────────────
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth >= 1100 ? 4 : (constraints.maxWidth >= 650 ? 2 : 1);
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: constraints.maxWidth >= 1100 ? 1.65 : 2.0,
                  children: [
                    StaggeredEntranceItem(
                      index: 0,
                      child: TechnicianStatCard(
                        title: 'Assigned Tests',
                        value: '${techState.assignedCount}',
                        subtitle: 'Total',
                        icon: Icons.assignment_outlined,
                        iconColor: const Color(0xFF2563EB),
                        iconBgColor: const Color(0xFFEFF6FF),
                        onTap: () => context.go('/lab-tech/assigned-tests'),
                      ),
                    ),
                    StaggeredEntranceItem(
                      index: 1,
                      child: TechnicianStatCard(
                        title: 'Pending Tests',
                        value: '${techState.pendingCount}',
                        subtitle: 'Pending',
                        icon: Icons.assignment_late_outlined,
                        iconColor: const Color(0xFFD97706),
                        iconBgColor: const Color(0xFFFEF3C7),
                        onTap: () => context.go('/lab-tech/assigned-tests'),
                      ),
                    ),
                    StaggeredEntranceItem(
                      index: 2,
                      child: TechnicianStatCard(
                        title: 'In Progress',
                        value: techState.inProgressCount < 10 ? '0${techState.inProgressCount}' : '${techState.inProgressCount}',
                        subtitle: 'In Progress',
                        icon: Icons.biotech,
                        iconColor: const Color(0xFF0284C7),
                        iconBgColor: const Color(0xFFE0F2FE),
                        onTap: () => context.go('/lab-tech/samples'),
                      ),
                    ),
                    StaggeredEntranceItem(
                      index: 3,
                      child: TechnicianStatCard(
                        title: 'Completed Today',
                        value: techState.completedTodayCount < 10 ? '0${techState.completedTodayCount}' : '${techState.completedTodayCount}',
                        subtitle: 'Completed',
                        icon: Icons.check_circle_outline,
                        iconColor: const Color(0xFF059669),
                        iconBgColor: const Color(0xFFD1FAE5),
                        onTap: () => context.go('/lab-tech/completed'),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 28),

            // ── RECENT ASSIGNED TESTS TABLE / CARD ────────────────────────────
            Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Table Card Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Assigned Tests',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/lab-tech/assigned-tests'),
                          child: const Row(
                            children: [
                              Text('View All', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                              Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF2563EB)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Data Table View for Desktop / Responsive List View for Mobile
                  if (isDesktop)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 320),
                        child: DataTable(
                          headingRowHeight: 48,
                          dataRowMaxHeight: 64,
                          horizontalMargin: 20,
                          columnSpacing: 24,
                          columns: const [
                            DataColumn(label: Text('Patient / Sample', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Test', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Sample ID', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Priority', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: techState.assignedTests.take(5).map((test) {
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
                                          fontSize: 13,
                                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                                        ),
                                      ),
                                      Text(
                                        'PID: ${test.patientId} | ${test.patientAgeGender.split(' ').take(2).join(' ')}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    test.testName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.white70 : const Color(0xFF334155),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    test.sampleId,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                ),
                                DataCell(SampleStatusChip.fromPriority(test.priority)),
                                DataCell(SampleStatusChip.fromAssignedStatus(test.status)),
                                DataCell(
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        test.appointmentDate,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                                        ),
                                      ),
                                      Text(
                                        test.appointmentTime,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF94A3B8)),
                                    onPressed: () {
                                      context.go('/lab-tech/test-processing?sampleId=${test.sampleId}');
                                    },
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: techState.assignedTests.take(5).length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final test = techState.assignedTests[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          title: Text(test.patientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text('${test.testName} • ${test.sampleId}', style: const TextStyle(fontSize: 12)),
                          trailing: SampleStatusChip.fromAssignedStatus(test.status),
                          onTap: () {
                            context.go('/lab-tech/test-processing?sampleId=${test.sampleId}');
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
