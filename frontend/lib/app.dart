import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astha_diagnostic/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/locale_provider.dart';
import 'routes/app_router.dart';

class AsthaDiagnosticApp extends ConsumerWidget {
  const AsthaDiagnosticApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppRouter.configure(ref);
    final activeLocale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Astha Diagnostic',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      locale: activeLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routeInformationParser: AppRouter.router.routeInformationParser,
      routerDelegate: AppRouter.router.routerDelegate,
      routeInformationProvider: AppRouter.router.routeInformationProvider,
      restorationScopeId: 'app',
      builder: (context, child) {
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
