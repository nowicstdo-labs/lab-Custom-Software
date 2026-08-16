import 'package:flutter/material.dart';
import '../../services/camera_service.dart';

class CameraPreviewWidget extends StatefulWidget {
  final String title;
  final bool isScannerMode;
  final ValueChanged<String>? onScanResult;
  final ValueChanged<String>? onPhotoCaptured;
  final VoidCallback? onCancel;

  const CameraPreviewWidget({
    super.key,
    this.title = 'Camera Scanner',
    this.isScannerMode = true,
    this.onScanResult,
    this.onPhotoCaptured,
    this.onCancel,
  });

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> with SingleTickerProviderStateMixin {
  final CameraService _cameraService = CameraService.instance;
  late AnimationController _scanController;
  CameraPermissionState _permissionState = CameraPermissionState.granted;
  CameraFlashMode _flashMode = CameraFlashMode.off;
  CameraLensDirection _lensDirection = CameraLensDirection.back;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _initCamera();
  }

  Future<void> _initCamera() async {
    setState(() => _isLoading = true);
    final state = await _cameraService.requestCameraPermission();
    if (!mounted) return;
    setState(() {
      _permissionState = state;
      _flashMode = _cameraService.flashMode;
      _lensDirection = _cameraService.lensDirection;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    _cameraService.dispose();
    super.dispose();
  }

  void _toggleFlash() {
    setState(() {
      _cameraService.toggleFlash();
      _flashMode = _cameraService.flashMode;
    });
  }

  void _switchCamera() {
    setState(() {
      _cameraService.switchCamera();
      _lensDirection = _cameraService.lensDirection;
    });
  }

  void _simulatedCapture() async {
    final imagePath = await _cameraService.capturePhoto();
    if (widget.onPhotoCaptured != null) {
      widget.onPhotoCaptured!(imagePath);
    }
  }

  void _simulatedScan([String mockSampleId = 'SMP10024']) {
    if (widget.onScanResult != null) {
      widget.onScanResult!(mockSampleId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Container(
        height: 380,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF14B8A6)),
              SizedBox(height: 16),
              Text('Initializing camera...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }

    // ── PERMISSION DENIED UI ──────────────────────────────────────────────────
    if (_permissionState == CameraPermissionState.denied) {
      return _buildErrorCard(
        icon: Icons.camera_alt_outlined,
        title: 'Camera Permission Required',
        message: 'Camera permission is required for scanning and capturing photos.',
        buttonLabel: 'Try Again',
        onButtonPressed: _initCamera,
      );
    }

    // ── PERMISSION PERMANENTLY DENIED UI ──────────────────────────────────────
    if (_permissionState == CameraPermissionState.permanentlyDenied) {
      return _buildErrorCard(
        icon: Icons.no_photography_outlined,
        title: 'Permission Disabled',
        message: 'Camera permission is disabled in your device settings. Please enable it from Settings to use the camera.',
        buttonLabel: 'Open Settings',
        onButtonPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Opening device settings...')),
          );
        },
      );
    }

    // ── CAMERA HARDWARE UNAVAILABLE UI ────────────────────────────────────────
    if (_permissionState == CameraPermissionState.unavailable) {
      return _buildErrorCard(
        icon: Icons.videocam_off_outlined,
        title: 'Camera Unavailable',
        message: 'No physical camera device was detected on this hardware. Scanner simulation mode active.',
        buttonLabel: 'Simulate Scan',
        onButtonPressed: () => _simulatedScan('SMP10024'),
      );
    }

    // ── LIVE CAMERA / SCANNER PREVIEW UI ──────────────────────────────────────
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 600),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.black,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background Live Viewfinder Simulation Gradient
            Container(
              height: 380,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.black,
                    _lensDirection == CameraLensDirection.back
                        ? const Color(0xFF1E293B)
                        : const Color(0xFF0F172A),
                  ],
                  radius: 1.2,
                ),
              ),
            ),

            // Top Camera Controls Bar (Flash & Switch Camera)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      _flashMode == CameraFlashMode.on ? Icons.flash_on : Icons.flash_off,
                      color: _flashMode == CameraFlashMode.on ? const Color(0xFFF59E0B) : Colors.white70,
                    ),
                    onPressed: _toggleFlash,
                    tooltip: _flashMode == CameraFlashMode.on ? 'Flash On' : 'Flash Off',
                  ),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.flip_camera_ios, color: Colors.white70),
                    onPressed: _switchCamera,
                    tooltip: 'Switch Camera',
                  ),
                ],
              ),
            ),

            // Scanner Viewfinder Overlay Frame (for QR/Barcode scanning mode)
            if (widget.isScannerMode) ...[
              Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF14B8A6), width: 2.5),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              AnimatedBuilder(
                animation: _scanController,
                builder: (context, child) {
                  return Positioned(
                    top: 100 + (_scanController.value * 180),
                    child: Container(
                      width: 210,
                      height: 3,
                      decoration: BoxDecoration(
                        color: const Color(0xFF14B8A6),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF14B8A6).withValues(alpha: 0.8),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],

            // Bottom Trigger Action Controls
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  if (widget.isScannerMode) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _simulatedScan('SMP10024'),
                          icon: const Icon(Icons.qr_code_scanner, size: 18),
                          label: const Text('Scan Sample'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _simulatedScan('SMP10025'),
                          icon: const Icon(Icons.line_weight, size: 18),
                          label: const Text('Scan Barcode'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF14B8A6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    ElevatedButton.icon(
                      onPressed: _simulatedCapture,
                      icon: const Icon(Icons.camera_alt, size: 20),
                      label: const Text('Capture Photo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard({
    required IconData icon,
    required String title,
    required String message,
    required String buttonLabel,
    required VoidCallback onButtonPressed,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFFEE2E2),
            child: Icon(icon, color: const Color(0xFFDC2626), size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onButtonPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}
