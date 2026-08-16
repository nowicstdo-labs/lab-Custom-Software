import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_models.dart';
import 'auth_service.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _service = AuthService();
  final StreamController<AuthState> _authStream = StreamController<AuthState>.broadcast();

  AuthNotifier() : super(const AuthState(isAuthenticated: false)) {
    _authStream.add(state);
    _initialize();
  }

  Stream<AuthState> get authStateStream => _authStream.stream;

  Future<void> _initialize() async {
    final rememberMe = await _service.loadRememberMe();
    final biometricEnabled = await _service.loadBiometricEnabled();
    final savedRefreshToken = await _service.loadSavedRefreshToken();

    state = state.copyWith(rememberMe: rememberMe, biometricEnabled: biometricEnabled);

    if (savedRefreshToken != null && rememberMe) {
      // Try to restore the actual user from the mock DB.
      // Falls back to a generic patient session if no in-memory user is found
      // (e.g. after a cold start where the DB is re-initialized).
      final currentMockUser = _service.getCurrentUser();
      final restoredRole = currentMockUser?.role ?? UserRole.patient;
      final restoredName = currentMockUser?.name ?? 'Restored User';
      final restoredEmail = currentMockUser?.email ?? 'refresh@astha.com';
      final user = AppUser(
        id: 'u-${restoredRole.name}-restore',
        name: restoredName,
        email: restoredEmail,
        role: restoredRole,
      );
      state = state.copyWith(
        isAuthenticated: true,
        user: user,
        accessToken: 'restored-access-${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: savedRefreshToken,
        authMethod: AuthMethod.emailPassword,
        sessions: [
          AuthSession(
            id: 'restored-session',
            deviceName: 'Current device',
            refreshToken: savedRefreshToken,
            issuedAt: DateTime.now(),
          ),
        ],
      );
      _authStream.add(state);
    }
  }

  /// Authenticates using the mock database — role is determined by the stored account.
  /// This is the primary login method for the role-based flow.
  Future<void> loginWithMockDB({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    final account = await _service.login(email: email, password: password);
    final tokens = await _service.loginWithEmailPassword(
      email: account.email,
      password: account.password,
      role: account.role,
    );
    final user = AppUser(
      id: 'u-${account.role.name}-${account.email.hashCode}',
      name: account.name,
      email: account.email,
      role: account.role,
    );
    await _updateAuthState(
        user: user, tokens: tokens, authMethod: AuthMethod.emailPassword, rememberMe: rememberMe);
  }

  /// Registers a new patient account in the mock database.
  Future<void> registerPatient({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final tokens = await _service.registerPatient(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );
    final user = AppUser(
      id: 'u-patient-${email.hashCode}',
      name: name,
      email: email,
      role: UserRole.patient,
    );
    await _updateAuthState(
        user: user, tokens: tokens, authMethod: AuthMethod.emailPassword, rememberMe: false);
  }

  /// Adds a staff member account (Admin-only operation).
  Future<void> addStaffMember({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    await _service.addStaffMember(
      name: name,
      email: email,
      phone: phone,
      password: password,
      role: role,
    );
  }

  Future<void> loginWithEmailPassword({
    required String email,
    required String password,
    required UserRole role,
    bool rememberMe = false,
  }) async {
    final tokens = await _service.loginWithEmailPassword(email: email, password: password, role: role);
    final user = AppUser(
      id: 'u-${role.name}-001',
      name: role.displayName == 'Patient' ? 'Aarav Patel' : '${role.displayName} User',
      email: email,
      role: role,
    );
    await _updateAuthState(user: user, tokens: tokens, authMethod: AuthMethod.emailPassword, rememberMe: rememberMe);
  }

  Future<void> loginWithGoogle({required UserRole role, bool rememberMe = false}) async {
    final tokens = await _service.loginWithGoogle(role: role);
    final user = AppUser(
      id: 'u-${role.name}-google',
      name: tokens.userName,
      email: tokens.userEmail,
      role: role,
    );
    await _updateAuthState(user: user, tokens: tokens, authMethod: AuthMethod.google, rememberMe: rememberMe);
  }

  Future<String> sendMobileOtp({required String mobile}) async {
    final otp = await _service.sendMobileOtp(mobile);
    state = state.copyWith(otpSent: true, otpDestination: mobile);
    _authStream.add(state);
    return otp;
  }

  Future<void> verifyMobileOtp({
    required String mobile,
    required String otp,
    required UserRole role,
    bool rememberMe = false,
  }) async {
    final tokens = await _service.verifyMobileOtp(mobile: mobile, otp: otp, role: role);
    final user = AppUser(
      id: 'u-${role.name}-mobile',
      name: role.displayName == 'Patient' ? 'Mobile Patient' : '${role.displayName} User',
      email: '$mobile@astha.com',
      mobile: mobile,
      role: role,
    );
    await _updateAuthState(user: user, tokens: tokens, authMethod: AuthMethod.mobileOtp, rememberMe: rememberMe);
  }

  Future<void> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final tokens = await _service.registerWithEmail(name: name, email: email, password: password, role: role);
    final user = AppUser(id: 'u-${role.name}-register', name: name, email: email, role: role);
    await _updateAuthState(user: user, tokens: tokens, authMethod: AuthMethod.emailPassword, rememberMe: true);
  }

  Future<void> registerWithMobile({
    required String name,
    required String mobile,
    required String password,
    required UserRole role,
  }) async {
    final tokens = await _service.registerWithMobile(name: name, mobile: mobile, password: password, role: role);
    final user = AppUser(id: 'u-${role.name}-register', name: name, email: '$mobile@astha.com', mobile: mobile, role: role);
    await _updateAuthState(user: user, tokens: tokens, authMethod: AuthMethod.mobileOtp, rememberMe: true);
  }

  Future<void> sendPasswordReset({required String emailOrMobile}) async {
    await _service.sendPasswordReset(emailOrMobile: emailOrMobile);
    state = state.copyWith(otpSent: true, otpDestination: emailOrMobile);
    _authStream.add(state);
  }

  Future<void> resetPassword({required String resetToken, required String password}) async {
    await _service.resetPassword(resetToken: resetToken, password: password);
  }

  Future<bool> isBiometricAvailable() => _service.isBiometricAvailable();

  Future<bool> authenticateBiometric() => _service.authenticateBiometric();

  Future<void> enableBiometric(bool enabled) async {
    await _service.saveBiometricEnabled(enabled);
    state = state.copyWith(biometricEnabled: enabled);
    _authStream.add(state);
  }

  Future<void> refreshSession({required String refreshToken, required UserRole role}) async {
    final tokens = await _service.refreshSession(refreshToken, role);
    final user = AppUser(id: 'u-${role.name}-restore', name: tokens.userName, email: tokens.userEmail, role: role);
    await _updateAuthState(user: user, tokens: tokens, authMethod: AuthMethod.emailPassword, rememberMe: true);
  }

  Future<void> logout() async {
    _service.logout(); // Clear mock DB session
    await _service.clearSavedSession();
    state = const AuthState(isAuthenticated: false);
    _authStream.add(state);
  }

  /// Returns the currently authenticated mock user from the DB, or null.
  MockAccount? getCurrentUser() => _service.getCurrentUser();

  /// Returns all staff members from the mock database.
  List<MockAccount> getAllStaff() => _service.getAllStaff();

  Future<void> logoutAllDevices() async {
    await _service.logoutAllDevices();
    state = const AuthState(isAuthenticated: false);
    _authStream.add(state);
  }

  Future<void> setRememberMe(bool rememberMe) async {
    state = state.copyWith(rememberMe: rememberMe);
    _authStream.add(state);
  }

  Future<void> _updateAuthState({
    required AppUser user,
    required AuthTokenResponse tokens,
    required AuthMethod authMethod,
    required bool rememberMe,
  }) async {
    final session = AuthSession(
      id: tokens.sessionId,
      deviceName: 'Current device',
      refreshToken: tokens.refreshToken,
      issuedAt: DateTime.now(),
    );
    if (rememberMe) {
      await _service.persistSession(refreshToken: tokens.refreshToken, rememberMe: rememberMe, sessionId: tokens.sessionId);
    }

    state = AuthState(
      isAuthenticated: true,
      user: user,
      authMethod: authMethod,
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      rememberMe: rememberMe,
      biometricEnabled: state.biometricEnabled,
      otpSent: false,
      otpDestination: null,
      sessions: [session],
    );
    _authStream.add(state);
  }
}
