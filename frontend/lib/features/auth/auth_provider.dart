import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
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
    final savedAccessToken = await _service.loadSavedAccessToken();
    final savedRefreshToken = await _service.loadSavedRefreshToken();
    final savedUser = await _service.loadSavedUserSession();

    state = state.copyWith(rememberMe: rememberMe, biometricEnabled: biometricEnabled);

    if (savedRefreshToken != null && savedRefreshToken.isNotEmpty) {
      if (savedAccessToken != null && savedAccessToken.isNotEmpty) {
        ApiService.setAuthToken(savedAccessToken);
      }
      ApiService.refreshToken = savedRefreshToken;

      bool isValid = false;
      if (savedAccessToken != null && savedAccessToken.isNotEmpty) {
        final res = await ApiService.get('/auth/me');
        if (res['success'] == true) {
          isValid = true;
        }
      }

      if (!isValid) {
        isValid = await ApiService.refreshAccessToken();
      }

      if (isValid && ApiService.accessToken != null) {
        final activeAccessToken = ApiService.accessToken!;
        final activeRefreshToken = ApiService.refreshToken ?? savedRefreshToken;
        final user = savedUser ?? const AppUser(
          id: 'restored-user',
          name: 'Authenticated User',
          email: 'user@astha.com',
          role: UserRole.patient,
        );

        state = AuthState(
          isAuthenticated: true,
          user: user,
          accessToken: activeAccessToken,
          refreshToken: activeRefreshToken,
          rememberMe: rememberMe,
          biometricEnabled: biometricEnabled,
          sessions: [
            AuthSession(
              id: 'restored-session',
              deviceName: 'Current device',
              refreshToken: activeRefreshToken,
              issuedAt: DateTime.now(),
            ),
          ],
        );
        _authStream.add(state);
        return;
      }
    }

    await _service.clearSavedSession();
    state = const AuthState(isAuthenticated: false);
    _authStream.add(state);
  }

  Future<void> loginWithMockDB({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    final account = await _service.login(email: email, password: password);
    final user = AppUser(
      id: 'u-${account.role.name}-${account.email.hashCode}',
      name: account.name,
      email: account.email,
      mobile: account.phone,
      role: account.role,
    );
    final tokens = AuthTokenResponse(
      accessToken: ApiService.accessToken ?? 'token-${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: ApiService.refreshToken ?? 'refresh-${DateTime.now().millisecondsSinceEpoch}',
      sessionId: user.id,
      userName: user.name,
      userEmail: user.email,
      userRole: user.role,
    );
    await _updateAuthState(
      user: user,
      tokens: tokens,
      authMethod: AuthMethod.emailPassword,
      rememberMe: rememberMe,
    );
  }

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
    final role = tokens.userRole ?? UserRole.patient;
    final user = AppUser(
      id: tokens.sessionId,
      name: name,
      email: email,
      mobile: phone,
      role: role,
    );
    await _updateAuthState(
      user: user,
      tokens: tokens,
      authMethod: AuthMethod.emailPassword,
      rememberMe: true,
    );
  }

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
    bool rememberMe = true,
  }) async {
    final tokens = await _service.loginWithEmailPassword(email: email, password: password, role: role);
    final actualRole = tokens.userRole ?? role;
    final user = AppUser(
      id: tokens.sessionId,
      name: tokens.userName,
      email: email,
      role: actualRole,
    );
    await _updateAuthState(user: user, tokens: tokens, authMethod: AuthMethod.emailPassword, rememberMe: rememberMe);
  }

  Future<void> loginWithGoogle({required UserRole role, bool rememberMe = true}) async {
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
    bool rememberMe = true,
  }) async {
    final tokens = await _service.verifyMobileOtp(mobile: mobile, otp: otp, role: role);
    final user = AppUser(
      id: 'u-${role.name}-mobile',
      name: tokens.userName,
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
    await registerPatient(name: name, email: email, phone: '', password: password);
  }

  Future<void> registerWithMobile({
    required String name,
    required String mobile,
    required String password,
    required UserRole role,
  }) async {
    await registerPatient(name: name, email: '$mobile@astha.com', phone: mobile, password: password);
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
    final user = AppUser(id: tokens.sessionId, name: tokens.userName, email: tokens.userEmail, role: tokens.userRole ?? role);
    await _updateAuthState(user: user, tokens: tokens, authMethod: AuthMethod.emailPassword, rememberMe: true);
  }

  Future<void> logout() async {
    _service.logout();
    await _service.clearSavedSession();
    state = const AuthState(isAuthenticated: false);
    _authStream.add(state);
  }

  MockAccount? getCurrentUser() => _service.getCurrentUser();

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
    await _service.persistSession(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      user: user,
      rememberMe: rememberMe,
    );

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

