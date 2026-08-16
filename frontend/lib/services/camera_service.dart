import 'dart:async';

enum CameraPermissionState {
  granted,
  denied,
  permanentlyDenied,
  unavailable,
}

enum CameraFlashMode {
  off,
  on,
  auto,
}

enum CameraLensDirection {
  back,
  front,
}

class CameraService {
  CameraService._();
  static final CameraService instance = CameraService._();

  CameraPermissionState _permissionState = CameraPermissionState.granted;
  CameraFlashMode _flashMode = CameraFlashMode.off;
  CameraLensDirection _lensDirection = CameraLensDirection.back;
  bool _isInitialized = false;

  CameraPermissionState get permissionState => _permissionState;
  CameraFlashMode get flashMode => _flashMode;
  CameraLensDirection get lensDirection => _lensDirection;
  bool get isInitialized => _isInitialized;

  /// Requests camera permission and returns the resulting permission state.
  Future<CameraPermissionState> requestCameraPermission() async {
    await Future.delayed(const Duration(milliseconds: 400));
    // In web/desktop or normal dev environment, permission is granted by default
    _isInitialized = true;
    return _permissionState;
  }

  /// Toggles camera flash between OFF and ON.
  void toggleFlash() {
    if (_flashMode == CameraFlashMode.off) {
      _flashMode = CameraFlashMode.on;
    } else {
      _flashMode = CameraFlashMode.off;
    }
  }

  /// Switches camera between BACK and FRONT lenses.
  void switchCamera() {
    if (_lensDirection == CameraLensDirection.back) {
      _lensDirection = CameraLensDirection.front;
    } else {
      _lensDirection = CameraLensDirection.back;
    }
  }

  /// For testing & debugging permission states: sets simulated permission state.
  void setSimulatedPermissionState(CameraPermissionState state) {
    _permissionState = state;
  }

  /// Simulates photo capture and returns a mock captured photo path or URL.
  Future<String> capturePhoto() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return 'captured_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
  }

  /// Disposes resources when camera screen closes.
  void dispose() {
    _isInitialized = false;
  }
}
