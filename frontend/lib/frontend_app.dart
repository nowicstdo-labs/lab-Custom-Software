import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'core/config/app_config.dart';

// ============================================================================
// ENVIRONMENT MODE SWITCH & REST API CLIENT
// ============================================================================

/// When true: Uses offline mock data for development.
/// When false: Connects to live NestJS REST API (https://astha-diagnostic-2.onrender.com/api/v1).
// ignore: constant_identifier_names
const bool MOCK_MODE = false;

class AsthaApiClient {
  static String get baseUrl => AppConfig.apiBaseUrl;
  static String? accessToken;
  static String? refreshToken;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      };

  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      return _handleResponse(response, () => post(endpoint, body));
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl$endpoint'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      return _handleResponse(response, () => get(endpoint));
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> _handleResponse(
    http.Response response,
    Future<Map<String, dynamic>> Function() retryCall,
  ) async {
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 401 && refreshToken != null) {
      final refreshed = await _refreshAccessToken();
      if (refreshed) {
        return await retryCall();
      }
    }

    return decoded;
  }

  static Future<bool> _refreshAccessToken() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        accessToken = decoded['data']?['accessToken'];
        refreshToken = decoded['data']?['refreshToken'];
        return true;
      }
    } catch (_) {}

    accessToken = null;
    refreshToken = null;
    return false;
  }
}

// ============================================================================
// 1. DESIGN SYSTEM — COLORS & TYPOGRAPHY & THEME
// ============================================================================

class AsthaColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryHover = Color(0xFF1D4ED8);
  static const Color accentTeal = Color(0xFF14B8A6);
  static const Color darkSidebar = Color(0xFF0F172A);
  static const Color darkSidebarCard = Color(0xFF1E293B);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF0B0F17);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
}

class AsthaTextStyles {
  static TextStyle get headline1 => GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: AsthaColors.textPrimary);
  static TextStyle get headline2 => GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AsthaColors.textPrimary);
  static TextStyle get headline3 => GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AsthaColors.textPrimary);
  static TextStyle get body => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal, color: AsthaColors.textPrimary);
  static TextStyle get subtitle => GoogleFonts.inter(fontSize: 13, color: AsthaColors.textSecondary);
}

class AsthaTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AsthaColors.primary,
      scaffoldBackgroundColor: AsthaColors.backgroundLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AsthaColors.primary,
        brightness: Brightness.light,
        primary: AsthaColors.primary,
        secondary: AsthaColors.accentTeal,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AsthaColors.textPrimary),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AsthaColors.primary,
      scaffoldBackgroundColor: AsthaColors.backgroundDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AsthaColors.primary,
        brightness: Brightness.dark,
        primary: AsthaColors.primary,
        secondary: AsthaColors.accentTeal,
        surface: const Color(0xFF1E293B),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F172A),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
    );
  }
}

// ============================================================================
// 2. CORE REUSABLE WIDGETS & ANIMATION COMPONENTS
// ============================================================================

class Astha3DCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final VoidCallback? onTap;
  final double scaleOnHover;
  final double elevation;

  const Astha3DCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.onTap,
    this.scaleOnHover = 1.015,
    this.elevation = 4.0,
  });

  @override
  State<Astha3DCard> createState() => _Astha3DCardState();
}

class _Astha3DCardState extends State<Astha3DCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveRadius = widget.borderRadius ?? BorderRadius.circular(16);
    final effectiveColor = widget.color ?? (isDark ? const Color(0xFF1E293B) : Colors.white);

    double currentScale = 1.0;
    if (_isPressed) {
      currentScale = 0.985;
    } else if (_isHovered) {
      currentScale = widget.scaleOnHover;
    }

    final double shadowBlur = _isHovered ? (widget.elevation * 3) : (widget.elevation * 2);
    final double shadowOffsetY = _isHovered ? (widget.elevation * 1.5) : (widget.elevation * 0.8);
    final double shadowOpacity = _isHovered ? (isDark ? 0.35 : 0.08) : (isDark ? 0.20 : 0.04);

    return Container(
      margin: widget.margin,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: currentScale,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: widget.padding ?? const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: effectiveColor,
                borderRadius: effectiveRadius,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: shadowOpacity),
                    blurRadius: shadowBlur,
                    offset: Offset(0, shadowOffsetY),
                  ),
                ],
                border: Border.all(
                  color: _isHovered
                      ? AsthaColors.primary.withValues(alpha: 0.3)
                      : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                  width: 1,
                ),
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class AsthaPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double pressScale;

  const AsthaPressable({
    super.key,
    required this.child,
    this.onPressed,
    this.pressScale = 0.97,
  });

  @override
  State<AsthaPressable> createState() => _AsthaPressableState();
}

class _AsthaPressableState extends State<AsthaPressable> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onPressed != null) setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        if (widget.onPressed != null) setState(() => _isPressed = false);
      },
      onTapCancel: () {
        if (widget.onPressed != null) setState(() => _isPressed = false);
      },
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? widget.pressScale : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.decelerate,
        child: widget.child,
      ),
    );
  }
}

class StaggeredEntranceItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration baseDelay;
  final Duration animationDuration;
  final double slideOffset;

  const StaggeredEntranceItem({
    super.key,
    required this.child,
    required this.index,
    this.baseDelay = const Duration(milliseconds: 60),
    this.animationDuration = const Duration(milliseconds: 350),
    this.slideOffset = 20.0,
  });

  @override
  State<StaggeredEntranceItem> createState() => _StaggeredEntranceItemState();
}

class _StaggeredEntranceItemState extends State<StaggeredEntranceItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.animationDuration);
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, widget.slideOffset / 100),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(widget.baseDelay * widget.index, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}

enum ThreeDIllustrationType { labTechnician, doctor, receptionist, testTubes, report, appointment }

class ThreeDIllustrationWidget extends StatelessWidget {
  final ThreeDIllustrationType type;
  final double height;
  final double width;

  const ThreeDIllustrationWidget({
    super.key,
    required this.type,
    this.height = 180,
    this.width = 180,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = type == ThreeDIllustrationType.labTechnician
        ? const Color(0xFF14B8A6)
        : (type == ThreeDIllustrationType.receptionist ? const Color(0xFF8B5CF6) : const Color(0xFF2563EB));

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            primaryColor.withValues(alpha: isDark ? 0.3 : 0.15),
            Colors.transparent,
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(_getIconForType(), size: height * 0.45, color: primaryColor),
          Positioned(
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Text(
                _getLabelForType(),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType() {
    switch (type) {
      case ThreeDIllustrationType.labTechnician:
        return Icons.biotech;
      case ThreeDIllustrationType.doctor:
        return Icons.medical_services;
      case ThreeDIllustrationType.receptionist:
        return Icons.support_agent;
      case ThreeDIllustrationType.testTubes:
        return Icons.science;
      case ThreeDIllustrationType.report:
        return Icons.assessment;
      case ThreeDIllustrationType.appointment:
        return Icons.calendar_month;
    }
  }

  String _getLabelForType() {
    switch (type) {
      case ThreeDIllustrationType.labTechnician:
        return 'Lab Tech Panel';
      case ThreeDIllustrationType.doctor:
        return 'Doctor Panel';
      case ThreeDIllustrationType.receptionist:
        return 'Receptionist Panel';
      case ThreeDIllustrationType.testTubes:
        return 'Diagnostics';
      case ThreeDIllustrationType.report:
        return 'Digital Reports';
      case ThreeDIllustrationType.appointment:
        return 'Appointments';
    }
  }
}

// ============================================================================
// 3. CAMERA & PERMISSION SERVICE & PREVIEW WIDGETS
// ============================================================================

enum CameraPermissionState { granted, denied, permanentlyDenied, unavailable }
enum CameraFlashMode { off, on, auto }
enum CameraLensDirection { back, front }

class CameraService {
  CameraService._();
  static final CameraService instance = CameraService._();

  final CameraPermissionState _permissionState = CameraPermissionState.granted;
  CameraFlashMode _flashMode = CameraFlashMode.off;
  CameraLensDirection _lensDirection = CameraLensDirection.back;

  CameraPermissionState get permissionState => _permissionState;
  CameraFlashMode get flashMode => _flashMode;
  CameraLensDirection get lensDirection => _lensDirection;

  Future<CameraPermissionState> requestCameraPermission() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _permissionState;
  }

  void toggleFlash() {
    _flashMode = _flashMode == CameraFlashMode.off ? CameraFlashMode.on : CameraFlashMode.off;
  }

  void switchCamera() {
    _lensDirection = _lensDirection == CameraLensDirection.back ? CameraLensDirection.front : CameraLensDirection.back;
  }

  Future<String> capturePhoto() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 'captured_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
  }

  void dispose() {}
}

class CameraPreviewWidget extends StatefulWidget {
  final String title;
  final bool isScannerMode;
  final ValueChanged<String>? onScanResult;
  final ValueChanged<String>? onPhotoCaptured;

  const CameraPreviewWidget({
    super.key,
    this.title = 'Camera Scanner',
    this.isScannerMode = true,
    this.onScanResult,
    this.onPhotoCaptured,
  });

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> with SingleTickerProviderStateMixin {
  final CameraService _service = CameraService.instance;
  late AnimationController _scanController;
  CameraPermissionState _permissionState = CameraPermissionState.granted;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _init();
  }

  Future<void> _init() async {
    setState(() => _isLoading = true);
    final st = await _service.requestCameraPermission();
    if (!mounted) return;
    setState(() {
      _permissionState = st;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Container(
        height: 360,
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
        child: const Center(
          child: CircularProgressIndicator(color: AsthaColors.accentTeal),
        ),
      );
    }

    if (_permissionState == CameraPermissionState.denied) {
      return _buildErrorCard(
        icon: Icons.camera_alt_outlined,
        title: 'Camera Permission Required',
        message: 'Camera permission is required for scanning and capturing photos.',
        buttonLabel: 'Try Again',
        onPressed: _init,
      );
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 600),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.black,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AsthaColors.primary.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 2),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 360,
              decoration: const BoxDecoration(
                gradient: RadialGradient(colors: [Colors.black, Color(0xFF1E293B)], radius: 1.2),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      _service.flashMode == CameraFlashMode.on ? Icons.flash_on : Icons.flash_off,
                      color: _service.flashMode == CameraFlashMode.on ? const Color(0xFFF59E0B) : Colors.white70,
                    ),
                    onPressed: () => setState(() => _service.toggleFlash()),
                  ),
                  Text(widget.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  IconButton(
                    icon: const Icon(Icons.flip_camera_ios, color: Colors.white70),
                    onPressed: () => setState(() => _service.switchCamera()),
                  ),
                ],
              ),
            ),
            if (widget.isScannerMode) ...[
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  border: Border.all(color: AsthaColors.accentTeal, width: 2.5),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              AnimatedBuilder(
                animation: _scanController,
                builder: (context, child) {
                  return Positioned(
                    top: 90 + (_scanController.value * 170),
                    child: Container(
                      width: 200,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AsthaColors.accentTeal,
                        boxShadow: [
                          BoxShadow(color: AsthaColors.accentTeal.withValues(alpha: 0.8), blurRadius: 10, spreadRadius: 2),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
            Positioned(
              bottom: 20,
              child: widget.isScannerMode
                  ? Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => widget.onScanResult?.call('SMP10024'),
                          icon: const Icon(Icons.qr_code_scanner, size: 18),
                          label: const Text('Scan Sample'),
                          style: ElevatedButton.styleFrom(backgroundColor: AsthaColors.primary, foregroundColor: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => widget.onScanResult?.call('SMP10025'),
                          icon: const Icon(Icons.line_weight, size: 18),
                          label: const Text('Scan Barcode'),
                          style: ElevatedButton.styleFrom(backgroundColor: AsthaColors.accentTeal, foregroundColor: Colors.white),
                        ),
                      ],
                    )
                  : ElevatedButton.icon(
                      onPressed: () async {
                        final path = await _service.capturePhoto();
                        widget.onPhotoCaptured?.call(path);
                      },
                      icon: const Icon(Icons.camera_alt, size: 20),
                      label: const Text('Capture Photo'),
                      style: ElevatedButton.styleFrom(backgroundColor: AsthaColors.primary, foregroundColor: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard({required IconData icon, required String title, required String message, required String buttonLabel, required VoidCallback onPressed}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Icon(icon, color: Colors.red, size: 36),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Text(message, style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onPressed, child: Text(buttonLabel)),
        ],
      ),
    );
  }
}

class ImagePickerDialogWidget extends StatefulWidget {
  final String title;
  final ValueChanged<String> onImageSelected;

  const ImagePickerDialogWidget({
    super.key,
    this.title = 'Upload Document or Photo',
    required this.onImageSelected,
  });

  static Future<void> show(BuildContext context, {String title = 'Upload Document or Photo', required ValueChanged<String> onImageSelected}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ImagePickerDialogWidget(title: title, onImageSelected: onImageSelected),
    );
  }

  @override
  State<ImagePickerDialogWidget> createState() => _ImagePickerDialogWidgetState();
}

class _ImagePickerDialogWidgetState extends State<ImagePickerDialogWidget> {
  bool _isTakingPhoto = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AsthaColors.textPrimary)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            if (_isTakingPhoto)
              CameraPreviewWidget(
                title: 'Capture Photo',
                isScannerMode: false,
                onPhotoCaptured: (path) {
                  widget.onImageSelected(path);
                  Navigator.pop(context);
                },
              )
            else ...[
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AsthaColors.primary),
                title: const Text('Take Photo', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Capture using device camera'),
                onTap: () => setState(() => _isTakingPhoto = true),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AsthaColors.accentTeal),
                title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Select photo from local gallery'),
                onTap: () {
                  widget.onImageSelected('gallery_photo_${DateTime.now().millisecondsSinceEpoch}.jpg');
                  Navigator.pop(context);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 4. AUTHENTICATION & ROLE MODELS & MOCK SERVICES
// ============================================================================

enum UserRole { patient, receptionist, labTechnician, doctor, admin }

class AppUser {
  final String id;
  final String email;
  final String name;
  final UserRole role;

  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'role': role.name,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: UserRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => UserRole.patient,
      ),
    );
  }

  String get roleDisplayName {
    switch (role) {
      case UserRole.patient:
        return 'Patient';
      case UserRole.receptionist:
        return 'Receptionist';
      case UserRole.labTechnician:
        return 'Lab Technician';
      case UserRole.doctor:
        return 'Doctor';
      case UserRole.admin:
        return 'Lab Owner / Admin';
    }
  }

  String get defaultDashboardPath {
    switch (role) {
      case UserRole.patient:
        return '/patient';
      case UserRole.receptionist:
        return '/receptionist';
      case UserRole.labTechnician:
        return '/lab-tech';
      case UserRole.doctor:
        return '/doctor';
      case UserRole.admin:
        return '/admin';
    }
  }
}

class MockUserDatabase {
  static final List<Map<String, dynamic>> users = [
    {
      'id': 'USR-001',
      'email': 'patient@astha.com',
      'password': 'password',
      'name': 'Patient User',
      'role': UserRole.patient,
    },
    {
      'id': 'USR-002',
      'email': 'receptionist@astha.com',
      'password': 'password',
      'name': 'Anita Sharma',
      'role': UserRole.receptionist,
    },
    {
      'id': 'USR-003',
      'email': 'labtech@astha.com',
      'password': 'password',
      'name': 'Rohit Sharma',
      'role': UserRole.labTechnician,
    },
    {
      'id': 'USR-004',
      'email': 'doctor@astha.com',
      'password': 'password',
      'name': 'Dr. Priya Mehta',
      'role': UserRole.doctor,
    },
    {
      'id': 'USR-005',
      'email': 'admin@asthadiagnostic.com',
      'password': 'Admin@123',
      'name': 'Dr. Astha Verma',
      'role': UserRole.admin,
    },
  ];

  static AppUser? authenticate(String email, String password) {
    try {
      final found = users.firstWhere(
        (u) => (u['email'] as String).toLowerCase() == email.trim().toLowerCase() && u['password'] == password,
      );
      return AppUser(
        id: found['id'],
        email: found['email'],
        name: found['name'],
        role: found['role'],
      );
    } catch (_) {
      return null;
    }
  }

  static AppUser registerPatient(String name, String email, String password) {
    final newUser = {
      'id': 'USR-${users.length + 1}',
      'email': email,
      'password': password,
      'name': name,
      'role': UserRole.patient,
    };
    users.add(newUser);
    return AppUser(id: newUser['id'] as String, email: email, name: name, role: UserRole.patient);
  }

  static AppUser addStaffMember(String name, String email, String password, UserRole role) {
    final newUser = {
      'id': 'STAFF-${users.length + 1}',
      'email': email,
      'password': password,
      'name': name,
      'role': role,
    };
    users.add(newUser);
    return AppUser(id: newUser['id'] as String, email: email, name: name, role: role);
  }
}

class AsthaAuthState {
  final AppUser? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;

  const AsthaAuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage,
  });

  AsthaAuthState copyWith({
    AppUser? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AsthaAuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  String get redirectPath => isAuthenticated && user != null ? user!.defaultDashboardPath : '/login';
}

class AuthNotifier extends StateNotifier<AsthaAuthState> {
  AuthNotifier() : super(const AsthaAuthState()) {
    _loadSavedUser();
  }

  Future<void> _loadSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    if (savedEmail != null) {
      try {
        final found = MockUserDatabase.users.firstWhere((u) => u['email'] == savedEmail);
        state = AsthaAuthState(
          user: AppUser(id: found['id'], email: found['email'], name: found['name'], role: found['role']),
          isAuthenticated: true,
        );
      } catch (_) {}
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    if (!MOCK_MODE) {
      final res = await AsthaApiClient.post('/auth/login', {'email': email, 'password': password});
      if (res['success'] == true && res['data'] != null) {
        final userData = res['data']['user'];
        AsthaApiClient.accessToken = res['data']['accessToken'];
        AsthaApiClient.refreshToken = res['data']['refreshToken'];

        final roleStr = (userData['role'] as String).toLowerCase();
        UserRole role = UserRole.patient;
        if (roleStr == 'receptionist') role = UserRole.receptionist;
        if (roleStr == 'lab_technician') role = UserRole.labTechnician;
        if (roleStr == 'doctor') role = UserRole.doctor;
        if (roleStr == 'admin') role = UserRole.admin;

        final appUser = AppUser(
          id: userData['id'],
          email: userData['email'],
          name: userData['name'] ?? 'User',
          role: role,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_email', appUser.email);
        state = AsthaAuthState(user: appUser, isAuthenticated: true, isLoading: false);
        return true;
      } else {
        state = state.copyWith(isLoading: false, errorMessage: res['message'] ?? 'Invalid credentials');
        return false;
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 400));
      final appUser = MockUserDatabase.authenticate(email, password);

      if (appUser != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_email', appUser.email);
        state = AsthaAuthState(user: appUser, isAuthenticated: true, isLoading: false);
        return true;
      } else {
        state = state.copyWith(isLoading: false, errorMessage: 'Invalid email or password credentials');
        return false;
      }
    }
  }

  Future<bool> registerPatient(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    if (!MOCK_MODE) {
      final res = await AsthaApiClient.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
      });

      if (res['success'] == true && res['data'] != null) {
        final userData = res['data']['user'];
        AsthaApiClient.accessToken = res['data']['accessToken'];
        AsthaApiClient.refreshToken = res['data']['refreshToken'];

        final appUser = AppUser(
          id: userData['id'],
          email: userData['email'],
          name: name,
          role: UserRole.patient, // Public registration strictly assigns patient
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_email', appUser.email);
        state = AsthaAuthState(user: appUser, isAuthenticated: true, isLoading: false);
        return true;
      } else {
        state = state.copyWith(isLoading: false, errorMessage: res['message'] ?? 'Registration failed');
        return false;
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 400));
      final appUser = MockUserDatabase.registerPatient(name, email, password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_email', appUser.email);
      state = AsthaAuthState(user: appUser, isAuthenticated: true, isLoading: false);
      return true;
    }
  }

  Future<void> logout() async {
    if (!MOCK_MODE && AsthaApiClient.accessToken != null) {
      await AsthaApiClient.post('/auth/logout', {});
    }
    AsthaApiClient.accessToken = null;
    AsthaApiClient.refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_email');
    state = const AsthaAuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AsthaAuthState>((ref) => AuthNotifier());

// ============================================================================
// 5. DOMAIN DATA MODELS & SHARED STATE NOTIFIER
// ============================================================================

class TestBooking {
  final String bookingId;
  final String patientId;
  final String patientName;
  final String patientDob;
  final String testName;
  final String appointmentDate;
  final String timeSlot;
  final double price;
  final String status;
  final String sampleStatus;
  final String reportStatus;

  const TestBooking({
    required this.bookingId,
    required this.patientId,
    required this.patientName,
    required this.patientDob,
    required this.testName,
    required this.appointmentDate,
    required this.timeSlot,
    required this.price,
    required this.status,
    required this.sampleStatus,
    required this.reportStatus,
  });

  Map<String, dynamic> toJson() => {
        'bookingId': bookingId,
        'patientId': patientId,
        'patientName': patientName,
        'patientDob': patientDob,
        'testName': testName,
        'appointmentDate': appointmentDate,
        'timeSlot': timeSlot,
        'price': price,
        'status': status,
        'sampleStatus': sampleStatus,
        'reportStatus': reportStatus,
      };

  factory TestBooking.fromJson(Map<String, dynamic> json) {
    return TestBooking(
      bookingId: json['bookingId'] as String,
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String,
      patientDob: json['patientDob'] as String,
      testName: json['testName'] as String,
      appointmentDate: json['appointmentDate'] as String,
      timeSlot: json['timeSlot'] as String,
      price: (json['price'] as num).toDouble(),
      status: json['status'] as String,
      sampleStatus: json['sampleStatus'] as String,
      reportStatus: json['reportStatus'] as String,
    );
  }
}

class AsthaSharedState {
  final List<TestBooking> bookings;
  final Map<String, int> slotBookingsCount;

  const AsthaSharedState({
    required this.bookings,
    required this.slotBookingsCount,
  });

  bool isSlotFull(String slot) {
    return (slotBookingsCount[slot] ?? 0) >= 10;
  }

  int getSlotBookedCount(String slot) {
    return slotBookingsCount[slot] ?? 0;
  }
}

class SharedDataNotifier extends StateNotifier<AsthaSharedState> {
  AsthaSharedState get currentState => state;
  SharedDataNotifier()
      : super(AsthaSharedState(
          bookings: [
            const TestBooking(
              bookingId: 'ASTH-BK-9021',
              patientId: 'ASTH-P-000125',
              patientName: 'Rahul Kumar',
              patientDob: '12-05-1997',
              testName: 'Complete Blood Count (CBC)',
              appointmentDate: '14-08-2026',
              timeSlot: '10:00 AM',
              price: 450.0,
              status: 'Confirmed',
              sampleStatus: 'Sample Collected',
              reportStatus: 'Report Ready',
            ),
            const TestBooking(
              bookingId: 'ASTH-BK-9022',
              patientId: 'ASTH-P-000126',
              patientName: 'Suman Gupta',
              patientDob: '18-09-1988',
              testName: 'Lipid Profile',
              appointmentDate: '14-08-2026',
              timeSlot: '10:30 AM',
              price: 850.0,
              status: 'Confirmed',
              sampleStatus: 'Processing',
              reportStatus: 'In Progress',
            ),
          ],
          slotBookingsCount: {
            '09:00 AM': 3,
            '09:30 AM': 6,
            '10:00 AM': 4,
            '10:30 AM': 8,
            '11:00 AM': 10, // Full
            '11:30 AM': 2,
            '02:00 PM': 5,
            '03:00 PM': 1,
          },
        ));

  bool isSlotFull(String slot) {
    return (state.slotBookingsCount[slot] ?? 0) >= 10;
  }

  int getSlotBookedCount(String slot) {
    return state.slotBookingsCount[slot] ?? 0;
  }

  Future<bool> addBooking(TestBooking booking) async {
    final updatedSlots = Map<String, int>.from(state.slotBookingsCount);
    updatedSlots[booking.timeSlot] = (updatedSlots[booking.timeSlot] ?? 0) + 1;

    if (!MOCK_MODE) {
      final res = await AsthaApiClient.post('/bookings', {
        'testId': 'TEST-CBC',
        'appointmentDate': booking.appointmentDate,
        'timeSlot': booking.timeSlot,
        'price': booking.price,
      });

      if (res['success'] == true && res['data'] != null) {
        final serverBooking = res['data'];
        final newBooking = TestBooking(
          bookingId: serverBooking['bookingId'] ?? booking.bookingId,
          patientId: booking.patientId,
          patientName: booking.patientName,
          patientDob: booking.patientDob,
          testName: booking.testName,
          appointmentDate: booking.appointmentDate,
          timeSlot: booking.timeSlot,
          price: booking.price,
          status: 'Confirmed',
          sampleStatus: 'Pending',
          reportStatus: 'Awaiting',
        );

        state = AsthaSharedState(
          bookings: [newBooking, ...state.bookings],
          slotBookingsCount: updatedSlots,
        );
        return true;
      }
    }

    state = AsthaSharedState(
      bookings: [booking, ...state.bookings],
      slotBookingsCount: updatedSlots,
    );
    return true;
  }
}

final sharedDataProvider = StateNotifierProvider<SharedDataNotifier, AsthaSharedState>((ref) => SharedDataNotifier());

// ============================================================================
// 6. LAB TECHNICIAN MODELS & STATE NOTIFIER & COMPONENTS
// ============================================================================

enum TechSampleStage { sampleCollected, sampleReceived, processing, testing, resultEntered, completed }
enum ResultStatusFlag { normal, high, low }

class AssignedTestModel {
  final String sampleId;
  final String patientId;
  final String patientName;
  final String patientAgeGender;
  final String testName;
  final TechSampleStage status;
  final String priority;
  final String appointmentDate;
  final String appointmentTime;
  final String sampleType;

  const AssignedTestModel({
    required this.sampleId,
    required this.patientId,
    required this.patientName,
    required this.patientAgeGender,
    required this.testName,
    required this.status,
    required this.priority,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.sampleType,
  });

  AssignedTestModel copyWith({TechSampleStage? status}) {
    return AssignedTestModel(
      sampleId: sampleId,
      patientId: patientId,
      patientName: patientName,
      patientAgeGender: patientAgeGender,
      testName: testName,
      status: status ?? this.status,
      priority: priority,
      appointmentDate: appointmentDate,
      appointmentTime: appointmentTime,
      sampleType: sampleType,
    );
  }
}

class DynamicTestParameter {
  final String parameterName;
  final String referenceRange;
  final String unit;
  final String resultValue;
  final ResultStatusFlag status;
  final double? minVal;
  final double? maxVal;

  const DynamicTestParameter({
    required this.parameterName,
    required this.referenceRange,
    required this.unit,
    this.resultValue = '',
    this.status = ResultStatusFlag.normal,
    this.minVal,
    this.maxVal,
  });

  DynamicTestParameter copyWith({String? resultValue, ResultStatusFlag? status}) {
    return DynamicTestParameter(
      parameterName: parameterName,
      referenceRange: referenceRange,
      unit: unit,
      resultValue: resultValue ?? this.resultValue,
      status: status ?? this.status,
      minVal: minVal,
      maxVal: maxVal,
    );
  }
}

class AsthaLabTechState {
  final List<AssignedTestModel> assignedTests;
  final List<DynamicTestParameter> activeParameters;

  const AsthaLabTechState({
    required this.assignedTests,
    required this.activeParameters,
  });

  int get assignedCount => assignedTests.length;
  int get pendingCount => assignedTests.where((t) => t.status == TechSampleStage.sampleCollected || t.status == TechSampleStage.sampleReceived).length;
  int get inProgressCount => assignedTests.where((t) => t.status == TechSampleStage.processing || t.status == TechSampleStage.testing || t.status == TechSampleStage.resultEntered).length;
  int get completedTodayCount => assignedTests.where((t) => t.status == TechSampleStage.completed).length;
}

class LabTechNotifier extends StateNotifier<AsthaLabTechState> {
  LabTechNotifier()
      : super(const AsthaLabTechState(
          assignedTests: [
            AssignedTestModel(
              sampleId: 'SMP10024',
              patientId: 'ASTH-P-000125',
              patientName: 'Rahul Kumar',
              patientAgeGender: '29 Y / Male',
              testName: 'Complete Blood Count (CBC)',
              status: TechSampleStage.processing,
              priority: 'Urgent',
              appointmentDate: '14-08-2026',
              appointmentTime: '10:00 AM',
              sampleType: 'EDTA Blood (Whole Blood)',
            ),
            AssignedTestModel(
              sampleId: 'SMP10025',
              patientId: 'ASTH-P-000126',
              patientName: 'Suman Gupta',
              patientAgeGender: '35 Y / Female',
              testName: 'Lipid Profile',
              status: TechSampleStage.sampleReceived,
              priority: 'Routine',
              appointmentDate: '14-08-2026',
              appointmentTime: '10:30 AM',
              sampleType: 'Serum (Yellow Top)',
            ),
          ],
          activeParameters: [
            DynamicTestParameter(parameterName: 'Hemoglobin (Hb)', referenceRange: '13.0 - 17.0', unit: 'g/dL', resultValue: '14.2', minVal: 13.0, maxVal: 17.0),
            DynamicTestParameter(parameterName: 'Total RBC Count', referenceRange: '4.5 - 5.5', unit: 'mill/cumm', resultValue: '4.8', minVal: 4.5, maxVal: 5.5),
            DynamicTestParameter(parameterName: 'Total WBC Count', referenceRange: '4000 - 11000', unit: '/cumm', resultValue: '7200', minVal: 4000, maxVal: 11000),
            DynamicTestParameter(parameterName: 'Platelet Count', referenceRange: '150000 - 450000', unit: '/cumm', resultValue: '280000', minVal: 150000, maxVal: 450000),
          ],
        ));

  void selectTestParameters(String testName) {
    // Reset active parameters to guarantee ZERO cross-test parameter contamination
    List<DynamicTestParameter> newParams = [];

    if (testName.contains('Lipid')) {
      newParams = const [
        DynamicTestParameter(parameterName: 'Total Cholesterol', referenceRange: '125 - 200', unit: 'mg/dL', resultValue: '175', minVal: 125, maxVal: 200),
        DynamicTestParameter(parameterName: 'HDL Cholesterol', referenceRange: '40 - 60', unit: 'mg/dL', resultValue: '48', minVal: 40, maxVal: 60),
        DynamicTestParameter(parameterName: 'LDL Cholesterol', referenceRange: '0 - 100', unit: 'mg/dL', resultValue: '95', minVal: 0, maxVal: 100),
        DynamicTestParameter(parameterName: 'Triglycerides', referenceRange: '35 - 150', unit: 'mg/dL', resultValue: '110', minVal: 35, maxVal: 150),
      ];
    } else if (testName.contains('Thyroid')) {
      newParams = const [
        DynamicTestParameter(parameterName: 'T3 Total', referenceRange: '0.8 - 2.0', unit: 'ng/mL', resultValue: '1.2', minVal: 0.8, maxVal: 2.0),
        DynamicTestParameter(parameterName: 'T4 Total', referenceRange: '5.1 - 14.1', unit: 'ug/dL', resultValue: '8.5', minVal: 5.1, maxVal: 14.1),
        DynamicTestParameter(parameterName: 'TSH', referenceRange: '0.5 - 4.5', unit: 'uIU/mL', resultValue: '2.1', minVal: 0.5, maxVal: 4.5),
      ];
    } else {
      // Default: Complete Blood Count (CBC)
      newParams = const [
        DynamicTestParameter(parameterName: 'Hemoglobin (Hb)', referenceRange: '13.0 - 17.0', unit: 'g/dL', resultValue: '14.2', minVal: 13.0, maxVal: 17.0),
        DynamicTestParameter(parameterName: 'Total RBC Count', referenceRange: '4.5 - 5.5', unit: 'mill/cumm', resultValue: '4.8', minVal: 4.5, maxVal: 5.5),
        DynamicTestParameter(parameterName: 'Total WBC Count', referenceRange: '4000 - 11000', unit: '/cumm', resultValue: '7200', minVal: 4000, maxVal: 11000),
        DynamicTestParameter(parameterName: 'Platelet Count', referenceRange: '150000 - 450000', unit: '/cumm', resultValue: '280000', minVal: 150000, maxVal: 450000),
      ];
    }

    state = AsthaLabTechState(assignedTests: state.assignedTests, activeParameters: newParams);
  }

  void updateSampleStage(String sampleId, TechSampleStage stage) {
    state = AsthaLabTechState(
      assignedTests: state.assignedTests.map((t) => t.sampleId == sampleId ? t.copyWith(status: stage) : t).toList(),
      activeParameters: state.activeParameters,
    );
  }

  void updateParameterValue(int index, DynamicTestParameter updatedParam) {
    final updatedList = List<DynamicTestParameter>.from(state.activeParameters);
    updatedList[index] = updatedParam;
    state = AsthaLabTechState(assignedTests: state.assignedTests, activeParameters: updatedList);
  }
}

final labTechnicianProvider = StateNotifierProvider<LabTechNotifier, AsthaLabTechState>((ref) => LabTechNotifier());

class SampleStatusChipWidget extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const SampleStatusChipWidget({super.key, required this.label, required this.bg, required this.fg});

  factory SampleStatusChipWidget.fromStage(TechSampleStage stage) {
    switch (stage) {
      case TechSampleStage.sampleCollected:
        return const SampleStatusChipWidget(label: 'Collected', bg: Color(0xFFFEF3C7), fg: Color(0xFFD97706));
      case TechSampleStage.sampleReceived:
        return const SampleStatusChipWidget(label: 'Received', bg: Color(0xFFE0F2FE), fg: Color(0xFF0284C7));
      case TechSampleStage.processing:
        return const SampleStatusChipWidget(label: 'Processing', bg: Color(0xFFEDE9FE), fg: Color(0xFF7C3AED));
      case TechSampleStage.testing:
        return const SampleStatusChipWidget(label: 'Testing', bg: Color(0xFFE0E7FF), fg: Color(0xFF4338CA));
      case TechSampleStage.resultEntered:
        return const SampleStatusChipWidget(label: 'Result Entered', bg: Color(0xFFD1FAE5), fg: Color(0xFF059669));
      case TechSampleStage.completed:
        return const SampleStatusChipWidget(label: 'Completed', bg: Color(0xFFDCFCE7), fg: Color(0xFF15803D));
    }
  }

  factory SampleStatusChipWidget.fromResultFlag(ResultStatusFlag flag) {
    switch (flag) {
      case ResultStatusFlag.normal:
        return const SampleStatusChipWidget(label: 'NORMAL', bg: Color(0xFFD1FAE5), fg: Color(0xFF059669));
      case ResultStatusFlag.high:
        return const SampleStatusChipWidget(label: 'HIGH', bg: Color(0xFFFEE2E2), fg: Color(0xFFDC2626));
      case ResultStatusFlag.low:
        return const SampleStatusChipWidget(label: 'LOW', bg: Color(0xFFFEF3C7), fg: Color(0xFFD97706));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }
}

class TestStatusTimelineWidget extends StatelessWidget {
  final TechSampleStage currentStage;
  const TestStatusTimelineWidget({super.key, required this.currentStage});

  static const List<TechSampleStage> stages = [
    TechSampleStage.sampleCollected,
    TechSampleStage.sampleReceived,
    TechSampleStage.processing,
    TechSampleStage.testing,
    TechSampleStage.resultEntered,
    TechSampleStage.completed,
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = stages.indexOf(currentStage);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Test Workflow Progress', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(stages.length, (idx) {
                final isDone = idx <= currentIndex;
                return Row(
                  children: [
                    AnimatedScale(
                      scale: idx == currentIndex ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: isDone ? AsthaColors.primary : Colors.grey.shade400,
                        child: Icon(isDone ? Icons.check : Icons.circle, size: 14, color: Colors.white),
                      ),
                    ),
                    if (idx < stages.length - 1)
                      Container(
                        width: 30,
                        height: 2,
                        color: idx < currentIndex ? AsthaColors.primary : Colors.grey.shade300,
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class ResultInputFieldWidget extends StatelessWidget {
  final DynamicTestParameter parameter;
  final ValueChanged<DynamicTestParameter> onChanged;

  const ResultInputFieldWidget({super.key, required this.parameter, required this.onChanged});

  ResultStatusFlag _eval(String v) {
    final val = double.tryParse(v.trim());
    if (val == null) return ResultStatusFlag.normal;
    if (parameter.minVal != null && val < parameter.minVal!) return ResultStatusFlag.low;
    if (parameter.maxVal != null && val > parameter.maxVal!) return ResultStatusFlag.high;
    return ResultStatusFlag.normal;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(parameter.parameterName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text('Range: ${parameter.referenceRange}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: TextFormField(
              initialValue: parameter.resultValue,
              decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
              onChanged: (v) {
                final flag = _eval(v);
                onChanged(parameter.copyWith(resultValue: v, status: flag));
              },
            ),
          ),
          const SizedBox(width: 8),
          Text(parameter.unit, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 8),
          SampleStatusChipWidget.fromResultFlag(parameter.status),
        ],
      ),
    );
  }
}

// ============================================================================
// 7. DECLARATIVE ROUTER & ROLE ACCESS GUARDS
// ============================================================================

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/public',
    redirect: (context, state) {
      final isAuthRoute = state.uri.path == '/login' || state.uri.path == '/register' || state.uri.path == '/splash';
      if (!auth.isAuthenticated && !isAuthRoute && !state.uri.path.startsWith('/public')) {
        return '/login';
      }
      if (auth.isAuthenticated && isAuthRoute) {
        return auth.redirectPath;
      }
      if (auth.isAuthenticated && auth.user != null) {
        final role = auth.user!.role;
        if (state.uri.path.startsWith('/admin') && role != UserRole.admin) return auth.redirectPath;
        if (state.uri.path.startsWith('/lab-tech') && role != UserRole.labTechnician && role != UserRole.admin) return auth.redirectPath;
        if (state.uri.path.startsWith('/doctor') && role != UserRole.doctor && role != UserRole.admin) return auth.redirectPath;
        if (state.uri.path.startsWith('/receptionist') && role != UserRole.receptionist && role != UserRole.admin) return auth.redirectPath;
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/forgot', builder: (context, state) => const ForgotPasswordScreen()),

      // Public Routes
      GoRoute(path: '/public', pageBuilder: (context, state) => _fadePage(state, const PublicHomeScreen())),
      GoRoute(path: '/public/about', builder: (context, state) => const AboutScreen()),
      GoRoute(path: '/public/packages', builder: (context, state) => const HealthPackagesScreen()),
      GoRoute(path: '/public/tests', builder: (context, state) => const TestCatalogScreen()),
      GoRoute(
        path: '/public/book-test',
        builder: (context, state) => BookTestScreen(initialTestId: state.uri.queryParameters['testId']),
      ),
      GoRoute(path: '/public/doctors', builder: (context, state) => const DoctorListScreen()),
      GoRoute(
        path: '/public/book-appointment',
        builder: (context, state) => BookAppointmentScreen(doctorId: state.uri.queryParameters['doctorId']),
      ),
      GoRoute(path: '/public/my-tests', builder: (context, state) => const MyTestsScreen()),
      GoRoute(path: '/pdf-report', builder: (context, state) => A4PdfReportScreen(reportId: state.uri.queryParameters['reportId'])),

      // Dashboards
      GoRoute(path: '/patient', pageBuilder: (context, state) => _fadePage(state, const PatientDashboardScreen())),
      GoRoute(path: '/receptionist', pageBuilder: (context, state) => _fadePage(state, const ReceptionistDashboardScreen())),
      GoRoute(path: '/patients', builder: (context, state) => const PatientManagementScreen()),
      GoRoute(path: '/billing', builder: (context, state) => const BillingScreen()),
      GoRoute(path: '/audit-log', builder: (context, state) => const AuditLogScreen()),

      // Lab Technician 10 Screens
      GoRoute(path: '/lab-tech', pageBuilder: (context, state) => _fadePage(state, const LabTechnicianDashboardScreen())),
      GoRoute(path: '/lab-tech/assigned-tests', builder: (context, state) => const AssignedTestsScreen()),
      GoRoute(path: '/lab-tech/samples', builder: (context, state) => const SampleManagementScreen()),
      GoRoute(path: '/lab-tech/scanner', builder: (context, state) => const SampleScannerScreen()),
      GoRoute(
        path: '/lab-tech/test-processing',
        builder: (context, state) => TestProcessingScreen(sampleId: state.uri.queryParameters['sampleId']),
      ),
      GoRoute(
        path: '/lab-tech/result-entry',
        builder: (context, state) => ResultEntryScreen(sampleId: state.uri.queryParameters['sampleId']),
      ),
      GoRoute(
        path: '/lab-tech/report-preview',
        builder: (context, state) => TechnicianReportPreviewScreen(sampleId: state.uri.queryParameters['sampleId']),
      ),
      GoRoute(path: '/lab-tech/completed', builder: (context, state) => const CompletedTestsScreen()),
      GoRoute(path: '/lab-tech/notifications', builder: (context, state) => const TechnicianNotificationsScreen()),
      GoRoute(path: '/lab-tech/profile', builder: (context, state) => const TechnicianProfileScreen()),

      // Doctor & Admin
      GoRoute(path: '/doctor', pageBuilder: (context, state) => _fadePage(state, const DoctorDashboardScreen())),
      GoRoute(
        path: '/doctor/consultation',
        builder: (context, state) => ConsultationScreen(patientName: state.uri.queryParameters['patientName'] ?? 'Patient'),
      ),
      GoRoute(path: '/admin', pageBuilder: (context, state) => _fadePage(state, const AdminDashboardScreen())),
      GoRoute(path: '/admin/add-staff', builder: (context, state) => const AddStaffScreen()),
      GoRoute(path: '/admin/report-approval', builder: (context, state) => const ReportApprovalScreen()),
      GoRoute(path: '/admin/formulas', builder: (context, state) => const FormulaManagementScreen()),
    ],
  );
});

CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic), child: child);
    },
  );
}

// ============================================================================
// 8. AUTHENTICATION & PUBLIC SCREENS
// ============================================================================

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AsthaColors.darkSidebar,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.biotech, size: 64, color: AsthaColors.accentTeal),
            SizedBox(height: 16),
            Text('ASTHA DIAGNOSTIC', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController(text: 'receptionist@astha.com');
  final _passwordController = TextEditingController(text: 'password');

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Astha3DCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.biotech, color: AsthaColors.primary, size: 32),
                      SizedBox(width: 10),
                      Text('ASTHA DIAGNOSTIC', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Sign In to Account', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('Enter your registered email and password (No role dropdown required).', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outlined), border: OutlineInputBorder()),
                  ),
                  if (auth.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(auth.errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: auth.isLoading
                          ? null
                          : () {
                              ref.read(authProvider.notifier).login(_emailController.text, _passwordController.text);
                            },
                      style: ElevatedButton.styleFrom(backgroundColor: AsthaColors.primary, foregroundColor: Colors.white),
                      child: auth.isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Sign In'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(onPressed: () => context.go('/register'), child: const Text('Public Sign Up')),
                      TextButton(onPressed: () => context.go('/public'), child: const Text('Browse Public Catalog')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Patient Registration')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Astha3DCard(
              child: Column(
                children: [
                  const Text('Create Patient Account', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('Public registration automatically assigns Patient role.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 20),
                  TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
                  const SizedBox(height: 14),
                  TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
                  const SizedBox(height: 14),
                  TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(authProvider.notifier).registerPatient(_nameController.text, _emailController.text, _passwordController.text);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AsthaColors.primary, foregroundColor: Colors.white),
                    child: auth.isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Register Patient Account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: const Center(child: Text('Enter email to receive password reset link.')),
    );
  }
}

// ============================================================================
// 9. PUBLIC PATIENT MODULE & BOOKING FLOW WITH 10-SLOT CAPACITY
// ============================================================================

class PublicHomeScreen extends StatelessWidget {
  const PublicHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.biotech, color: AsthaColors.primary),
            SizedBox(width: 8),
            Text('ASTHA DIAGNOSTIC', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => context.go('/public/tests'), child: const Text('Tests')),
          TextButton(onPressed: () => context.go('/public/doctors'), child: const Text('Doctors')),
          ElevatedButton(onPressed: () => context.go('/login'), child: const Text('Login')),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Premium Diagnostic Care', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        const Text('Book home collection or doctor consultation in minutes.', style: TextStyle(color: Colors.white70)),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => context.go('/public/book-test'),
                              style: ElevatedButton.styleFrom(backgroundColor: AsthaColors.primary, foregroundColor: Colors.white),
                              child: const Text('Book Test'),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: () => context.go('/public/book-appointment'),
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                              child: const Text('Doctor Consult'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const ThreeDIllustrationWidget(type: ThreeDIllustrationType.testTubes, height: 180, width: 180),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Row(
              children: [
                Expanded(child: Astha3DCard(child: Text('Smart Booking', style: TextStyle(fontWeight: FontWeight.bold)))),
                SizedBox(width: 16),
                Expanded(child: Astha3DCard(child: Text('Digital Reports', style: TextStyle(fontWeight: FontWeight.bold)))),
                SizedBox(width: 16),
                Expanded(child: Astha3DCard(child: Text('Same Day Results', style: TextStyle(fontWeight: FontWeight.bold)))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('About Astha Diagnostic')), body: const Center(child: Text('About Section')));
}

class HealthPackagesScreen extends StatelessWidget {
  const HealthPackagesScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Health Packages')), body: const Center(child: Text('Packages Section')));
}

class TestCatalogScreen extends StatelessWidget {
  const TestCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostic Test Catalog')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Astha3DCard(
            onTap: () => context.go('/public/book-test?testId=t1'),
            child: const ListTile(
              title: Text('Complete Blood Count (CBC)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('28 Parameters • ₹450'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),
          const SizedBox(height: 12),
          Astha3DCard(
            onTap: () => context.go('/public/book-test?testId=t2'),
            child: const ListTile(
              title: Text('Lipid Profile', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Cholesterol & Triglycerides • ₹850'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class BookTestScreen extends ConsumerStatefulWidget {
  final String? initialTestId;
  const BookTestScreen({super.key, this.initialTestId});

  @override
  ConsumerState<BookTestScreen> createState() => _BookTestScreenState();
}

class _BookTestScreenState extends ConsumerState<BookTestScreen> {
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _dateController = TextEditingController(text: '14-08-2026');
  String _selectedSlot = '10:00 AM';
  String _selectedTest = 'Complete Blood Count (CBC)';

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) {
      controller.text = '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sharedData = ref.watch(sharedDataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Book Diagnostic Test')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Astha3DCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Test & Patient Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedTest,
                    decoration: const InputDecoration(labelText: 'Test Name', border: OutlineInputBorder()),
                    items: ['Complete Blood Count (CBC)', 'Lipid Profile', 'Thyroid Panel']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedTest = v!),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Patient Full Name', border: OutlineInputBorder())),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _dobController,
                    decoration: InputDecoration(
                      labelText: 'DOB (DD-MM-YYYY)',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(icon: const Icon(Icons.calendar_month), onPressed: () => _pickDate(_dobController)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Appointment Date (DD-MM-YYYY)',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(icon: const Icon(Icons.calendar_month), onPressed: () => _pickDate(_dateController)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Select Appointment Time Slot (Max 10 Capacity)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Time Slots Grid with 10-patient capacity logic & visual status
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: ['09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM'].map((slot) {
                final bookedCount = sharedData.getSlotBookedCount(slot);
                final isFull = bookedCount >= 10;
                final isSelected = _selectedSlot == slot;

                Color bg = isFull
                    ? const Color(0xFFFEE2E2)
                    : (bookedCount >= 8 ? const Color(0xFFFEF3C7) : const Color(0xFFD1FAE5));
                Color fg = isFull ? const Color(0xFFDC2626) : (bookedCount >= 8 ? const Color(0xFFD97706) : const Color(0xFF059669));

                return GestureDetector(
                  onTap: isFull ? null : () => setState(() => _selectedSlot = slot),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AsthaColors.primary : bg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isSelected ? AsthaColors.primary : fg),
                    ),
                    child: Column(
                      children: [
                        Text(slot, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : fg)),
                        const SizedBox(height: 2),
                        Text(
                          isFull ? 'FULL ($bookedCount/10)' : '$bookedCount/10 booked',
                          style: TextStyle(fontSize: 10, color: isSelected ? Colors.white70 : fg),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final newBooking = TestBooking(
                    bookingId: 'ASTH-BK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                    patientId: 'ASTH-P-000125',
                    patientName: _nameController.text,
                    patientDob: _dobController.text,
                    testName: _selectedTest,
                    appointmentDate: _dateController.text,
                    timeSlot: _selectedSlot,
                    price: 450.0,
                    status: 'Confirmed',
                    sampleStatus: 'Sample Collection Pending',
                    reportStatus: 'Awaiting Sample',
                  );
                  ref.read(sharedDataProvider.notifier).addBooking(newBooking);
                  context.go('/public/my-tests');
                },
                style: ElevatedButton.styleFrom(backgroundColor: AsthaColors.primary, foregroundColor: Colors.white),
                child: const Text('Confirm & Book Test'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorListScreen extends StatelessWidget {
  const DoctorListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Specialist Doctors')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Astha3DCard(
            onTap: () => context.go('/public/book-appointment?doctorId=d1'),
            child: const ListTile(
              leading: CircleAvatar(backgroundColor: AsthaColors.primary, child: Icon(Icons.person, color: Colors.white)),
              title: Text('Dr. Priya Mehta', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Senior Pathologist • 12 Yrs Exp'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class BookAppointmentScreen extends StatelessWidget {
  final String? doctorId;
  const BookAppointmentScreen({super.key, this.doctorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Doctor Consultation')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('Schedule Doctor Appointment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/patient'),
              child: const Text('Submit Appointment Request'),
            ),
          ],
        ),
      ),
    );
  }
}

class MyTestsScreen extends ConsumerWidget {
  const MyTestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedData = ref.watch(sharedDataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Test Bookings & Reports')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: sharedData.bookings.length,
        itemBuilder: (context, idx) {
          final b = sharedData.bookings[idx];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Astha3DCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(b.testName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AsthaColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                        child: Text(b.status, style: const TextStyle(color: AsthaColors.primary, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Booking ID: ${b.bookingId} | Patient: ${b.patientName}'),
                  Text('Date: ${b.appointmentDate} at ${b.timeSlot}'),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Sample: ${b.sampleStatus}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                      TextButton.icon(
                        icon: const Icon(Icons.picture_as_pdf, size: 16),
                        label: const Text('A4 Report PDF'),
                        onPressed: () => context.go('/pdf-report?reportId=${b.bookingId}'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// 10. RECEPTIONIST MODULE & DASHBOARD
// ============================================================================

class ReceptionistDashboardScreen extends ConsumerWidget {
  const ReceptionistDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedData = ref.watch(sharedDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receptionist Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => ref.read(authProvider.notifier).logout()),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: AsthaColors.darkSidebar, borderRadius: BorderRadius.circular(20)),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome back, Anita!', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        SizedBox(height: 6),
                        Text('Daily Lab Overview & Reception Desk Management', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const ThreeDIllustrationWidget(type: ThreeDIllustrationType.receptionist, height: 120, width: 120),
              ],
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ActionChip(label: const Text('Book Test'), avatar: const Icon(Icons.add_circle), onPressed: () => context.go('/public/book-test')),
                ActionChip(label: const Text('Scan QR / Barcode'), avatar: const Icon(Icons.qr_code_scanner), onPressed: () => context.go('/lab-tech/scanner')),
                ActionChip(label: const Text('Patient Entry'), avatar: const Icon(Icons.person_add), onPressed: () => context.go('/patients')),
                ActionChip(label: const Text('Billing'), avatar: const Icon(Icons.receipt), onPressed: () => context.go('/billing')),
              ],
            ),
            const SizedBox(height: 28),
            const Text('Recent Patient Bookings Queue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sharedData.bookings.length,
              itemBuilder: (context, idx) {
                final b = sharedData.bookings[idx];
                return Card(
                  child: ListTile(
                    title: Text('${b.patientName} (${b.patientId})', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${b.testName} • ${b.appointmentDate} ${b.timeSlot}'),
                    trailing: Text(b.status, style: const TextStyle(color: AsthaColors.primary, fontWeight: FontWeight.bold)),
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

class PatientManagementScreen extends StatelessWidget {
  const PatientManagementScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Patient Directory')), body: const Center(child: Text('Patient Directory Table')));
}

class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Billing & Invoices')), body: const Center(child: Text('Billing Module')));
}

class AuditLogScreen extends StatelessWidget {
  const AuditLogScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('System Audit Logs')), body: const Center(child: Text('Audit Logs')));
}

// ============================================================================
// 11. LAB TECHNICIAN 10-SCREEN PANEL MODULE
// ============================================================================

class LabTechScaffold extends ConsumerWidget {
  final String title;
  final String currentRoute;
  final Widget child;

  const LabTechScaffold({super.key, required this.title, required this.currentRoute, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lab Tech — $title'),
        backgroundColor: AsthaColors.darkSidebar,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => ref.read(authProvider.notifier).logout()),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: AsthaColors.darkSidebar),
              child: Text('ASTHA LAB TECH', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            ListTile(title: const Text('Dashboard'), onTap: () => context.go('/lab-tech')),
            ListTile(title: const Text('Assigned Tests'), onTap: () => context.go('/lab-tech/assigned-tests')),
            ListTile(title: const Text('Sample Management'), onTap: () => context.go('/lab-tech/samples')),
            ListTile(title: const Text('Scanner (QR/Barcode)'), onTap: () => context.go('/lab-tech/scanner')),
            ListTile(title: const Text('Completed Tests'), onTap: () => context.go('/lab-tech/completed')),
            ListTile(title: const Text('Notifications'), onTap: () => context.go('/lab-tech/notifications')),
            ListTile(title: const Text('Profile'), onTap: () => context.go('/lab-tech/profile')),
          ],
        ),
      ),
      body: child,
    );
  }
}

class LabTechnicianDashboardScreen extends ConsumerWidget {
  const LabTechnicianDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final techState = ref.watch(labTechnicianProvider);

    return LabTechScaffold(
      title: 'Dashboard',
      currentRoute: '/lab-tech',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Astha3DCard(child: Column(children: [const Text('Assigned'), Text('${techState.assignedCount}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))]))),
                const SizedBox(width: 12),
                Expanded(child: Astha3DCard(child: Column(children: [const Text('Pending'), Text('${techState.pendingCount}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))]))),
                const SizedBox(width: 12),
                Expanded(child: Astha3DCard(child: Column(children: [const Text('Completed'), Text('${techState.completedTodayCount}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))]))),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/lab-tech/scanner'),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Open QR / Barcode Scanner'),
            ),
          ],
        ),
      ),
    );
  }
}

class AssignedTestsScreen extends ConsumerWidget {
  const AssignedTestsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LabTechScaffold(
      title: 'Assigned Tests',
      currentRoute: '/lab-tech/assigned-tests',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Astha3DCard(
            onTap: () => context.go('/lab-tech/test-processing?sampleId=SMP10024'),
            child: const ListTile(
              title: Text('Rahul Kumar • SMP10024', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Complete Blood Count (CBC) • Urgent'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class SampleManagementScreen extends StatelessWidget {
  const SampleManagementScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const LabTechScaffold(
      title: 'Sample Management',
      currentRoute: '/lab-tech/samples',
      child: Center(child: Text('Sample Reception & Tracking')),
    );
  }
}

class SampleScannerScreen extends StatefulWidget {
  const SampleScannerScreen({super.key});

  @override
  State<SampleScannerScreen> createState() => _SampleScannerScreenState();
}

class _SampleScannerScreenState extends State<SampleScannerScreen> {
  String? _scannedId;

  @override
  Widget build(BuildContext context) {
    return LabTechScaffold(
      title: 'Scanner (QR / Barcode)',
      currentRoute: '/lab-tech/scanner',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CameraPreviewWidget(
              title: 'Sample Scanner',
              onScanResult: (id) => setState(() => _scannedId = id),
            ),
            if (_scannedId != null) ...[
              const SizedBox(height: 20),
              Astha3DCard(
                child: Column(
                  children: [
                    Text('Sample Verified: $_scannedId', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: OutlinedButton(onPressed: () => context.go('/lab-tech/test-processing?sampleId=$_scannedId'), child: const Text('View Sample'))),
                        const SizedBox(width: 12),
                        Expanded(child: ElevatedButton(onPressed: () => context.go('/lab-tech/result-entry?sampleId=$_scannedId'), child: const Text('Start Test'))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class TestProcessingScreen extends StatelessWidget {
  final String? sampleId;
  const TestProcessingScreen({super.key, this.sampleId});

  @override
  Widget build(BuildContext context) {
    return LabTechScaffold(
      title: 'Test Processing',
      currentRoute: '/lab-tech/test-processing',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const TestStatusTimelineWidget(currentStage: TechSampleStage.processing),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/lab-tech/result-entry?sampleId=${sampleId ?? 'SMP10024'}'),
              child: const Text('Proceed to Result Entry'),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultEntryScreen extends ConsumerWidget {
  final String? sampleId;
  const ResultEntryScreen({super.key, this.sampleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final techState = ref.watch(labTechnicianProvider);

    return LabTechScaffold(
      title: 'Result Entry',
      currentRoute: '/lab-tech/result-entry',
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Enter Parameter Values (Auto Reference Range Check)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          ...List.generate(techState.activeParameters.length, (idx) {
            final param = techState.activeParameters[idx];
            return ResultInputFieldWidget(
              parameter: param,
              onChanged: (updated) => ref.read(labTechnicianProvider.notifier).updateParameterValue(idx, updated),
            );
          }),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/lab-tech/report-preview?sampleId=${sampleId ?? 'SMP10024'}'),
            child: const Text('Save & Preview Report'),
          ),
        ],
      ),
    );
  }
}

class TechnicianReportPreviewScreen extends StatelessWidget {
  final String? sampleId;
  const TechnicianReportPreviewScreen({super.key, this.sampleId});

  @override
  Widget build(BuildContext context) {
    return LabTechScaffold(
      title: 'Report Preview',
      currentRoute: '/lab-tech/report-preview',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('Technician Report Preview (Verification Guarded)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/lab-tech/completed'),
              child: const Text('Mark Testing Completed'),
            ),
          ],
        ),
      ),
    );
  }
}

class CompletedTestsScreen extends StatelessWidget {
  const CompletedTestsScreen({super.key});
  @override
  Widget build(BuildContext context) => const LabTechScaffold(title: 'Completed Tests', currentRoute: '/lab-tech/completed', child: Center(child: Text('Completed Lab Reports')));
}

class TechnicianNotificationsScreen extends StatelessWidget {
  const TechnicianNotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) => const LabTechScaffold(title: 'Notifications', currentRoute: '/lab-tech/notifications', child: Center(child: Text('Technician Notifications')));
}

class TechnicianProfileScreen extends ConsumerWidget {
  const TechnicianProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LabTechScaffold(
      title: 'Profile',
      currentRoute: '/lab-tech/profile',
      child: Center(
        child: ElevatedButton(onPressed: () => ref.read(authProvider.notifier).logout(), child: const Text('Logout')),
      ),
    );
  }
}

// ============================================================================
// 12. DOCTOR & ADMIN MODULES
// ============================================================================

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Dashboard')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/doctor/consultation?patientName=Rahul%20Kumar'),
          child: const Text('Start Patient Consultation'),
        ),
      ),
    );
  }
}

class ConsultationScreen extends StatelessWidget {
  final String patientName;
  const ConsultationScreen({super.key, required this.patientName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Consultation: $patientName')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Clinical Notes & Vitals', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                ImagePickerDialogWidget.show(context, title: 'Attach Clinical Image', onImageSelected: (p) {});
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Attach Document / Take Photo'),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab Owner / Admin Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ListTile(title: const Text('Add Staff Account'), onTap: () => context.go('/admin/add-staff')),
          ListTile(title: const Text('Report Approval Queue'), onTap: () => context.go('/admin/report-approval')),
          ListTile(title: const Text('Formula Management'), onTap: () => context.go('/admin/formulas')),
        ],
      ),
    );
  }
}

class AddStaffScreen extends ConsumerStatefulWidget {
  const AddStaffScreen({super.key});
  @override
  ConsumerState<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends ConsumerState<AddStaffScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.labTechnician;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Staff Account')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Staff Name')),
            TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextFormField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password')),
            DropdownButton<UserRole>(
              value: _selectedRole,
              items: const [
                DropdownMenuItem(value: UserRole.receptionist, child: Text('Receptionist')),
                DropdownMenuItem(value: UserRole.labTechnician, child: Text('Lab Technician')),
                DropdownMenuItem(value: UserRole.doctor, child: Text('Doctor')),
                DropdownMenuItem(value: UserRole.admin, child: Text('Admin')),
              ],
              onChanged: (v) => setState(() => _selectedRole = v!),
            ),
            ElevatedButton(
              onPressed: () {
                MockUserDatabase.addStaffMember(_nameController.text, _emailController.text, _passwordController.text, _selectedRole);
                Navigator.pop(context);
              },
              child: const Text('Save Staff Account'),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportApprovalScreen extends StatelessWidget {
  const ReportApprovalScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Report Approvals')), body: const Center(child: Text('Pathology Approval Queue')));
}

class FormulaManagementScreen extends StatelessWidget {
  const FormulaManagementScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Formula Management Engine')), body: const Center(child: Text('Formulas')));
}

// ============================================================================
// 13. PRINTABLE A4 REPORT PREVIEW
// ============================================================================

class A4PdfReportScreen extends StatelessWidget {
  final String? reportId;
  const A4PdfReportScreen({super.key, this.reportId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('A4 Printable Medical Report')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300)),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ASTHA DIAGNOSTIC', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AsthaColors.primary)),
                    Text('ISO 9001:2015 CERTIFIED', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
                Divider(height: 32),
                Text('PATIENT REPORT: Rahul Kumar (29Y/M)'),
                Text('TEST: Complete Blood Count (CBC)'),
                SizedBox(height: 20),
                Text('Hemoglobin: 14.2 g/dL (Normal 13.0-17.0)'),
                Text('RBC: 4.8 mill/cumm (Normal 4.5-5.5)'),
                SizedBox(height: 30),
                Align(alignment: Alignment.centerRight, child: Text('Authorized Signatory\nDr. Priya Mehta (MD Path)')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PatientDashboardScreen extends ConsumerWidget {
  const PatientDashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Dashboard'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => ref.read(authProvider.notifier).logout())],
      ),
      body: Center(
        child: ElevatedButton(onPressed: () => context.go('/public/my-tests'), child: const Text('View My Test Reports')),
      ),
    );
  }
}

// ============================================================================
// 14. MAIN ROOT APPLICATION ENTRYPOINT
// ============================================================================

class AsthaDiagnosticApp extends ConsumerWidget {
  const AsthaDiagnosticApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Astha Diagnostic',
      debugShowCheckedModeBanner: false,
      theme: AsthaTheme.lightTheme,
      darkTheme: AsthaTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
