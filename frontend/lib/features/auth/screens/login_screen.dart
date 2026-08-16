import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:astha_diagnostic/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../auth_models.dart';
import '../auth_provider.dart';
import '../locale_provider.dart';

enum LoginMode { email, mobile }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = true;
  LoginMode _loginMode = LoginMode.email;
  bool _biometricSupported = false;
  bool _obscurePassword = true;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometricSupport();
    });
  }

  Future<void> _checkBiometricSupport() async {
    final supported = await ref.read(authProvider.notifier).isBiometricAvailable();
    if (mounted) {
      setState(() => _biometricSupported = supported);
    }
  }

  Future<void> _handleEmailLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // ── Empty field validation ───────────────────────────────────────────────
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your email and password.'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).loginWithMockDB(
            email: email,
            password: password,
            rememberMe: _rememberMe,
          );
      _finishLogin();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _handleSendOtp() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).sendMobileOtp(mobile: _mobileController.text.trim());
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP sent to your mobile number.')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send OTP: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleVerifyOtp() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).verifyMobileOtp(
            mobile: _mobileController.text.trim(),
            otp: _otpController.text.trim(),
            role: UserRole.patient,
            rememberMe: _rememberMe,
          );
      _finishLogin();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).loginWithGoogle(role: UserRole.patient, rememberMe: _rememberMe);
      _finishLogin();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google sign-in failed: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleBiometricLogin() async {
    setState(() => _isLoading = true);
    try {
      final isAuthenticated = await ref.read(authProvider.notifier).authenticateBiometric();
      if (mounted) {
        setState(() => _isLoading = false);
        if (isAuthenticated) {
          final redirect = ref.read(authProvider).redirectPath;
          context.go(redirect);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Biometric authentication failed.')));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Biometric authentication error: ${e.toString()}')),
        );
      }
    }
  }

  void _finishLogin() {
    setState(() => _isLoading = false);
    final redirect = ref.read(authProvider).redirectPath;
    if (mounted) {
      context.go(redirect);
    }
  }

  @override
  Widget build(BuildContext context) {
    final otpSent = ref.watch(authProvider).otpSent;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipPath(
                  clipper: HeaderClipper(),
                  child: Container(
                    height: screenHeight * 0.32,
                    width: double.infinity,
                    color: AppColors.primary,
                  ),
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
                        'assets/images/doctor.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      AppLocalizations.of(context)!.login_btn,
                      style: AppTextStyles.headline2.copyWith(
                        fontSize: 32,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _ModeToggle(selected: _loginMode, onSelected: (mode) => setState(() => _loginMode = mode)),
                  const SizedBox(height: 24),
                  if (_loginMode == LoginMode.email) ...[
                    AppTextField(
                      label: AppLocalizations.of(context)!.email_address_label,
                      hint: AppLocalizations.of(context)!.email_hint,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                    ),
                    const SizedBox(height: 18),
                    AppTextField(
                      label: AppLocalizations.of(context)!.password_label,
                      hint: AppLocalizations.of(context)!.password_hint,
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ] else ...[
                    AppTextField(
                      label: AppLocalizations.of(context)!.mobile_number_label,
                      hint: AppLocalizations.of(context)!.mobile_number_hint,
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primary),
                    ),
                    const SizedBox(height: 18),
                    if (otpSent)
                      AppTextField(
                        label: AppLocalizations.of(context)!.otp_label,
                        hint: AppLocalizations.of(context)!.otp_hint,
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.pin_outlined, color: AppColors.primary),
                      ),
                  ],
                  const SizedBox(height: 18),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            activeColor: AppColors.primary,
                            onChanged: (value) => setState(() => _rememberMe = value ?? true),
                          ),
                          Text(AppLocalizations.of(context)!.remember_me_checkbox, style: AppTextStyles.body),
                        ],
                      ),
                      TextButton(
                        onPressed: () => context.go('/forgot'),
                        child: Text(
                          AppLocalizations.of(context)!.forgot_password_btn,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _loginMode == LoginMode.email
                          ? _handleEmailLogin
                          : (otpSent ? _handleVerifyOtp : _handleSendOtp),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _loginMode == LoginMode.email 
                                  ? AppLocalizations.of(context)!.login_btn 
                                  : (otpSent 
                                      ? AppLocalizations.of(context)!.verify_otp 
                                      : AppLocalizations.of(context)!.send_otp),
                              style: AppTextStyles.button.copyWith(fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(child: Text(AppLocalizations.of(context)!.or, style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary))),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: _handleGoogleLogin,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.g_mobiledata, size: 30, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.continue_google, style: AppTextStyles.button.copyWith(color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                  if (_biometricSupported) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: _handleBiometricLogin,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: Text(AppLocalizations.of(context)!.use_biometric, style: AppTextStyles.button.copyWith(color: AppColors.primary)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/register'),
                      child: RichText(
                        text: TextSpan(
                          text: AppLocalizations.of(context)!.dont_have_account_text,
                          style: AppTextStyles.body,
                          children: [
                            TextSpan(
                              text: AppLocalizations.of(context)!.sign_up_btn,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _LanguagePicker(),
                  const SizedBox(height: 24),
                  const _DevCredentialsBanner(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final LoginMode selected;
  final ValueChanged<LoginMode> onSelected;

  const _ModeToggle({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: LoginMode.values.map((mode) {
        final active = mode == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelected(mode),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  mode == LoginMode.email 
                      ? AppLocalizations.of(context)!.email_tab 
                      : AppLocalizations.of(context)!.mobile_tab,
                  style: AppTextStyles.subtitle.copyWith(
                    color: active ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// _RolePicker removed — role is now determined automatically from the mock database on login.

class _LanguagePicker extends ConsumerWidget {
  const _LanguagePicker();

  void _showLanguageBottomSheet(BuildContext context, WidgetRef ref) {
    final activeLocale = ref.read(localeProvider);
    String tempSelectedLanguage = getLanguageName(activeLocale.languageCode);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withValues(alpha: 0.5),
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
                    _LanguageOptionTile(
                      languageName: 'English',
                      isSelected: tempSelectedLanguage == 'English',
                      onTap: () {
                        setSheetState(() => tempSelectedLanguage = 'English');
                      },
                    ),
                    _LanguageOptionTile(
                      languageName: 'বাংলা (Bengali)',
                      isSelected: tempSelectedLanguage == 'বাংলা (Bengali)',
                      onTap: () {
                        setSheetState(() => tempSelectedLanguage = 'বাংলা (Bengali)');
                      },
                    ),
                    _LanguageOptionTile(
                      languageName: 'हिन्दी (Hindi)',
                      isSelected: tempSelectedLanguage == 'हिन्दी (Hindi)',
                      onTap: () {
                        setSheetState(() => tempSelectedLanguage = 'हिन्दी (Hindi)');
                      },
                    ),
                    _LanguageOptionTile(
                      languageName: 'اردو (Urdu)',
                      isSelected: tempSelectedLanguage == 'اردو (Urdu)',
                      isRtl: true,
                      onTap: () {
                        setSheetState(() => tempSelectedLanguage = 'اردو (Urdu)');
                      },
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLocale = ref.watch(localeProvider);
    final selectedLanguageName = getLanguageName(activeLocale.languageCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.language_label,
          style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showLanguageBottomSheet(context, ref),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedLanguageName,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  final String languageName;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isRtl;

  const _LanguageOptionTile({
    required this.languageName,
    required this.isSelected,
    required this.onTap,
    this.isRtl = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = ListTile(
      onTap: onTap,
      title: Text(
        languageName,
        textAlign: isRtl ? TextAlign.right : TextAlign.left,
        style: AppTextStyles.body.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
    );

    if (isRtl) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: content,
      );
    }
    return content;
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

// =============================================================================
// DEV-ONLY: Test Credentials Panel
// This widget is only visible in debug builds (kDebugMode = true).
// It will NOT appear in production/release builds.
// =============================================================================

class _DevCredentialsBanner extends StatefulWidget {
  const _DevCredentialsBanner();

  @override
  State<_DevCredentialsBanner> createState() => _DevCredentialsBannerState();
}

class _DevCredentialsBannerState extends State<_DevCredentialsBanner> {
  bool _expanded = false;

  static const _creds = [
    ('patient@astha.com', 'password', 'Patient'),
    ('doctor@astha.com', 'password', 'Doctor'),
    ('receptionist@astha.com', 'password', 'Receptionist'),
    ('labtech@astha.com', 'password', 'Lab Technician'),
    ('admin@asthadiagnostic.com', 'Admin@123', 'Admin'),
  ];

  @override
  Widget build(BuildContext context) {
    // Only show during development — hidden in release builds
    const bool isDebug = bool.fromEnvironment('dart.vm.product') == false;
    if (!isDebug) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.developer_mode, color: Color(0xFFA06000), size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'DEV MODE — Test Credentials',
                      style: TextStyle(
                        color: Color(0xFFA06000),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFFA06000),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1, color: Color(0xFFFFD700)),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._creds.map(
                    (c) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              c.$3,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF7A4500),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${c.$1} / ${c.$2}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF5A3000),
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '⚠ Remove before production release.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFAA0000),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
