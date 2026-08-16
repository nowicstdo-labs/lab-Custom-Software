import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:astha_diagnostic/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../locale_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  void _showLanguageBottomSheet(BuildContext context) {
    final currentLangCode = ref.read(localeProvider).languageCode;
    String tempSelectedLanguage = getLanguageName(currentLangCode);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: Text(
                        AppLocalizations.of(context)!.select_language_title,
                        style: AppTextStyles.headline3.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, thickness: 0.5),
                    const SizedBox(height: 8),
                    _buildLanguageOptionTile(
                      context,
                      'English',
                      false,
                      tempSelectedLanguage == 'English',
                      () => setSheetState(() => tempSelectedLanguage = 'English'),
                    ),
                    _buildLanguageOptionTile(
                      context,
                      'বাংলা (Bengali)',
                      false,
                      tempSelectedLanguage == 'বাংলা (Bengali)',
                      () => setSheetState(() => tempSelectedLanguage = 'বাংলা (Bengali)'),
                    ),
                    _buildLanguageOptionTile(
                      context,
                      'हिन्दी (Hindi)',
                      false,
                      tempSelectedLanguage == 'हिन्दी (Hindi)',
                      () => setSheetState(() => tempSelectedLanguage = 'हिन्दी (Hindi)'),
                    ),
                    _buildLanguageOptionTile(
                      context,
                      'اردو (Urdu)',
                      true,
                      tempSelectedLanguage == 'اردو (Urdu)',
                      () => setSheetState(() => tempSelectedLanguage = 'اردو (Urdu)'),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          final code = getLanguageCode(tempSelectedLanguage);
                          ref.read(localeProvider.notifier).setLocale(code);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.done_btn,
                          style: AppTextStyles.button.copyWith(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLanguageOptionTile(
    BuildContext context,
    String lang,
    bool isRtl,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final textStyle = AppTextStyles.body.copyWith(
      color: isSelected ? AppColors.primary : AppColors.textPrimary,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      fontSize: 16,
    );

    Widget content = ListTile(
      onTap: onTap,
      title: Text(
        lang,
        textAlign: isRtl ? TextAlign.right : TextAlign.left,
        style: textStyle,
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : null,
    );

    if (isRtl) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: content,
      );
    }
    return content;
  }

  Widget _buildLanguageSelector(BuildContext context) {
    final activeLocale = ref.watch(localeProvider);

    return InkWell(
      onTap: () => _showLanguageBottomSheet(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              activeLocale.languageCode.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipPath(
                clipper: HeaderClipper(),
                child: Container(
                  height: screenHeight * 0.35,
                  width: double.infinity,
                  color: AppColors.primary,
                ),
              ),
              // Language Selector at top-right
              Positioned(
                top: topPadding + 10,
                right: 16,
                child: _buildLanguageSelector(context),
              ),
              // Character Illustration
              Positioned(
                bottom: -40,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    height: 290,
                    child: Image.asset(
                      'assets/images/researcher.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.welcome_title,
                    style: AppTextStyles.headline1.copyWith(
                      fontSize: 28,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!.welcome_subtitle,
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  // Filled Teal Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => context.go('/register'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.create_account_btn,
                        style: AppTextStyles.button.copyWith(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Outlined Teal Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () => context.go('/login'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.login_btn,
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.primary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height + 20,
      size.width,
      size.height - 60,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
