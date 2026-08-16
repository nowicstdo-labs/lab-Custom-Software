import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/lab_technician_provider.dart';

class LabTechScaffold extends ConsumerWidget {
  final String title;
  final String currentRoute;
  final Widget child;
  final List<Widget>? actions;

  const LabTechScaffold({
    super.key,
    required this.title,
    required this.currentRoute,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final techState = ref.watch(labTechnicianProvider);
    final techNotifier = ref.read(labTechnicianProvider.notifier);
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sidebarContent = _LabTechSidebarContent(
      currentRoute: currentRoute,
      profile: techState.profile,
      unreadCount: techState.unreadNotificationCount,
      isDark: isDark,
      onToggleTheme: () => techNotifier.toggleThemeMode(),
    );

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0.5,
        scrolledUnderElevation: 0,
        leading: isDesktop
            ? null
            : Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
        title: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        actions: actions ??
            [
              IconButton(
                icon: const Icon(Icons.search, size: 22),
                tooltip: 'Search',
                onPressed: () => context.push('/lab-tech/assigned-tests'),
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, size: 22),
                    tooltip: 'Notifications',
                    onPressed: () => context.push('/lab-tech/notifications'),
                  ),
                  if (techState.unreadNotificationCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${techState.unreadNotificationCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
            ],
      ),
      drawer: isDesktop
          ? null
          : Drawer(
              child: SafeArea(
                child: sidebarContent,
              ),
            ),
      body: Row(
        children: [
          if (isDesktop)
            SizedBox(
              width: 260,
              child: sidebarContent,
            ),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}

class _LabTechSidebarContent extends StatelessWidget {
  final String currentRoute;
  final TechProfile profile;
  final int unreadCount;
  final bool isDark;
  final VoidCallback onToggleTheme;

  const _LabTechSidebarContent({
    required this.currentRoute,
    required this.profile,
    required this.unreadCount,
    required this.isDark,
    required this.onToggleTheme,
  });

  static const _menuItems = [
    _SidebarItem(label: 'Dashboard', icon: Icons.dashboard_outlined, route: '/lab-tech'),
    _SidebarItem(label: 'Assigned Tests', icon: Icons.assignment_outlined, route: '/lab-tech/assigned-tests'),
    _SidebarItem(label: 'Sample Management', icon: Icons.biotech_outlined, route: '/lab-tech/samples'),
    _SidebarItem(label: 'Scanner (QR / Barcode)', icon: Icons.qr_code_scanner_outlined, route: '/lab-tech/scanner'),
    _SidebarItem(label: 'Test Processing', icon: Icons.precision_manufacturing_outlined, route: '/lab-tech/test-processing'),
    _SidebarItem(label: 'Result Entry', icon: Icons.edit_note_outlined, route: '/lab-tech/result-entry'),
    _SidebarItem(label: 'Completed Tests', icon: Icons.task_alt_outlined, route: '/lab-tech/completed'),
    _SidebarItem(label: 'Notifications', icon: Icons.notifications_none_outlined, route: '/lab-tech/notifications', isNotification: true),
    _SidebarItem(label: 'Profile', icon: Icons.person_outline, route: '/lab-tech/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    // Dark Blue Gradient sidebar background matching reference image
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Logo Section
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 16, top: 24, bottom: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.biotech, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ASTHA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'DIAGNOSTIC',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // User Profile Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF2563EB),
                    child: Text(
                      profile.name.substring(0, 1),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile.role,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Online',
                              style: TextStyle(
                                color: Color(0xFF34D399),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Navigation Links
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _menuItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final isSelected = currentRoute == item.route;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (Scaffold.of(context).isDrawerOpen) {
                        Navigator.of(context).pop();
                      }
                      if (currentRoute != item.route) {
                        context.go(item.route);
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          AnimatedScale(
                            scale: isSelected ? 1.1 : 1.0,
                            duration: const Duration(milliseconds: 240),
                            child: Icon(
                              item.icon,
                              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 240),
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                fontSize: 13,
                              ),
                              child: Text(item.label),
                            ),
                          ),
                          if (item.isNotification && unreadCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : const Color(0xFF2563EB),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$unreadCount',
                                style: TextStyle(
                                  color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Theme Mode Toggle
          Padding(
            padding: const EdgeInsets.all(16),
            child: Material(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onToggleTheme,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                        color: const Color(0xFFCBD5E1),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isDark ? 'Light Mode' : 'Dark Mode',
                        style: const TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem {
  final String label;
  final IconData icon;
  final String route;
  final bool isNotification;

  const _SidebarItem({
    required this.label,
    required this.icon,
    required this.route,
    this.isNotification = false,
  });
}
