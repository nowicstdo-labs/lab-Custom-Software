import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../utils/responsive.dart';
import '../../auth/auth_models.dart';
import '../../auth/auth_provider.dart';
import 'role_sidebar.dart';

class DashboardScaffold extends ConsumerWidget {
  final String title;
  final Widget child;
  final String currentRoute;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const DashboardScaffold({
    super.key,
    required this.title,
    required this.child,
    required this.currentRoute,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final isDesktop = Responsive.isDesktop(context);
    final sidebar = RoleSidebar(
      role: user?.role ?? UserRole.patient,
      currentRoute: currentRoute,
      onItemSelected: (route) {
        if (route != currentRoute) {
          context.go(route);
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions ??
            [
              IconButton(
                icon: const Icon(Icons.search, color: AppColors.primary),
                tooltip: 'Global Search',
                onPressed: () => context.push('/global-search'),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
                tooltip: 'Notification Center',
                onPressed: () => context.push('/notification-center'),
              ),
              const SizedBox(width: 8),
            ],
        leading: isDesktop
            ? null
            : Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  );
                },
              ),
      ),
      drawer: isDesktop ? null : Drawer(child: SafeArea(child: sidebar)),
      body: Row(
        children: [
          if (isDesktop)
            SizedBox(
              width: 280,
              child: sidebar,
            ),
          Expanded(
            child: Container(
              color: AppColors.background,
              child: child,
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
