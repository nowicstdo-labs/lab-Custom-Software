import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../auth/auth_models.dart';

class DashboardSidebarItem {
  final String label;
  final IconData icon;
  final String route;

  const DashboardSidebarItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}

class RoleSidebar extends StatelessWidget {
  final UserRole role;
  final String currentRoute;
  final ValueChanged<String>? onItemSelected;

  const RoleSidebar({
    super.key,
    required this.role,
    required this.currentRoute,
    this.onItemSelected,
  });

  static const Map<UserRole, List<DashboardSidebarItem>> _roleMenuItems = {
    UserRole.patient: [
      DashboardSidebarItem(label: 'Home', icon: Icons.home, route: '/patient'),
      DashboardSidebarItem(label: 'My Tests', icon: Icons.biotech, route: '/public/my-tests'),
      DashboardSidebarItem(label: 'Reports', icon: Icons.description, route: '/public/my-tests'),
      DashboardSidebarItem(label: 'Book Test', icon: Icons.add_circle, route: '/public/book-test'),
      DashboardSidebarItem(label: 'Doctor Appointment', icon: Icons.calendar_month, route: '/public/book-appointment'),
      DashboardSidebarItem(label: 'Notification Center', icon: Icons.notifications, route: '/notification-center'),
      DashboardSidebarItem(label: 'My Bills', icon: Icons.receipt_long, route: '/public/my-bills'),
      DashboardSidebarItem(label: 'Profile', icon: Icons.person, route: '/public/profile'),
    ],
    UserRole.receptionist: [
      DashboardSidebarItem(label: 'Dashboard', icon: Icons.dashboard, route: '/receptionist'),
      DashboardSidebarItem(label: 'Patient Records', icon: Icons.groups, route: '/patients'),
      DashboardSidebarItem(label: 'Book Test / Walk-in', icon: Icons.person_add, route: '/public/book-test'),
      DashboardSidebarItem(label: 'Sample Entry', icon: Icons.water_drop, route: '/lab-tech/samples'),
      DashboardSidebarItem(label: 'Report Builder', icon: Icons.edit_document, route: '/report-builder'),
      DashboardSidebarItem(label: 'Billing & Invoices', icon: Icons.receipt_long, route: '/billing'),
      DashboardSidebarItem(label: 'Global Search', icon: Icons.search, route: '/global-search'),
      DashboardSidebarItem(label: 'Notification Center', icon: Icons.notifications, route: '/notification-center'),
      DashboardSidebarItem(label: 'Audit Log', icon: Icons.security, route: '/audit-log'),
    ],
    UserRole.labTechnician: [
      DashboardSidebarItem(label: 'Dashboard', icon: Icons.dashboard, route: '/lab-tech'),
      DashboardSidebarItem(label: 'Sample Tracking', icon: Icons.biotech, route: '/lab-tech/samples'),
      DashboardSidebarItem(label: 'Enter Test Results', icon: Icons.edit_note, route: '/lab-tech/result-entry'),
      DashboardSidebarItem(label: 'Report Builder', icon: Icons.edit_document, route: '/report-builder'),
      DashboardSidebarItem(label: 'Formula Engine', icon: Icons.functions, route: '/admin/formulas'),
      DashboardSidebarItem(label: 'Notification Center', icon: Icons.notifications, route: '/notification-center'),
    ],
    UserRole.doctor: [
      DashboardSidebarItem(label: 'Dashboard', icon: Icons.dashboard, route: '/doctor'),
      DashboardSidebarItem(label: 'My Patients', icon: Icons.groups, route: '/patients'),
      DashboardSidebarItem(label: 'Today’s Appointments', icon: Icons.calendar_today, route: '/doctor'),
      DashboardSidebarItem(label: 'New Consultation', icon: Icons.note_add, route: '/doctor/consultation'),
      DashboardSidebarItem(label: 'Notification Center', icon: Icons.notifications, route: '/notification-center'),
    ],
    UserRole.admin: [
      DashboardSidebarItem(label: 'Dashboard Overview', icon: Icons.dashboard, route: '/admin'),
      DashboardSidebarItem(label: 'Report Approvals Queue', icon: Icons.approval, route: '/admin/report-approval'),
      DashboardSidebarItem(label: 'Formula Engine Mgmt', icon: Icons.functions, route: '/admin/formulas'),
      DashboardSidebarItem(label: 'Manage Staff Accounts', icon: Icons.manage_accounts, route: '/admin/add-staff'),
      DashboardSidebarItem(label: 'Patient Management', icon: Icons.groups, route: '/patients'),
      DashboardSidebarItem(label: 'Billing & Invoices', icon: Icons.receipt_long, route: '/billing'),
      DashboardSidebarItem(label: 'Global Search', icon: Icons.search, route: '/global-search'),
      DashboardSidebarItem(label: 'System Audit Logs', icon: Icons.security, route: '/audit-log'),
      DashboardSidebarItem(label: 'Notification Center', icon: Icons.notifications, route: '/notification-center'),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final items = _roleMenuItems[role] ?? _roleMenuItems[UserRole.patient]!;

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${role.displayName} Panel', style: AppTextStyles.headline3.copyWith(fontSize: 20)),
          const SizedBox(height: 4),
          const Text('Astha Diagnostic Management', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                final selected = item.route == currentRoute;
                return Material(
                  color: selected ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      if (onItemSelected != null) {
                        onItemSelected!(item.route);
                      } else {
                        context.push(item.route);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                      child: Row(
                        children: [
                          Icon(item.icon, color: selected ? AppColors.primary : AppColors.textSecondary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.label,
                              style: AppTextStyles.subtitle.copyWith(
                                color: selected ? AppColors.primary : AppColors.textPrimary,
                                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (selected) const Icon(Icons.arrow_right, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
