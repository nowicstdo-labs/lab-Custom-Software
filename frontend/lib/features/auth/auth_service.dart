// =============================================================================
// TODO: Replace with real backend authentication before production.
// This mock authentication system is ONLY for frontend development and testing.
// Do NOT use real passwords, JWT tokens, or production database here.
// See backend implementation guide before going live.
// =============================================================================

import 'dart:async';
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_models.dart';
import '../../services/api_service.dart';

// ---------------------------------------------------------------------------
// Mock User Database
// ---------------------------------------------------------------------------

/// A single account record stored in the mock database.
class MockAccount {
  final String name;
  final String email;
  final String phone;
  final String password;
  final UserRole role;

  MockAccount({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
  });
}

/// In-memory singleton that acts as the mock backend user store.
/// Pre-seeded with one demo account per role for development convenience.
class MockUserDatabase {
  MockUserDatabase._();
  static final MockUserDatabase instance = MockUserDatabase._();

  final List<MockAccount> _accounts = [
    // =========================================================================
    // DEVELOPMENT-ONLY MOCK ACCOUNTS
    // These are temporary accounts for frontend development and testing.
    // Admin account: admin@asthadiagnostic.com / Admin@123
    // NEVER expose these credentials in production UI.
    // =========================================================================
    MockAccount(
      name: 'Aarav Patel',
      email: 'patient@astha.com',
      phone: '+919876543210',
      password: 'password',
      role: UserRole.patient,
    ),
    MockAccount(
      name: 'Dr. Priya Sharma',
      email: 'doctor@astha.com',
      phone: '+919876543211',
      password: 'password',
      role: UserRole.doctor,
    ),
    MockAccount(
      name: 'Ritu Verma',
      email: 'receptionist@astha.com',
      phone: '+919876543212',
      password: 'password',
      role: UserRole.receptionist,
    ),
    MockAccount(
      name: 'Rohit Sharma',
      email: 'labtech@astha.com',
      phone: '+919876543213',
      password: 'password',
      role: UserRole.labTechnician,
    ),
    // ── DEV-ONLY Admin account ──────────────────────────────────────────────
    // IMPORTANT: This is a DEVELOPMENT-ONLY mock admin account.
    // Replace with real backend admin management before production.
    MockAccount(
      name: 'Astha Diagnostic Admin',
      email: 'admin@asthadiagnostic.com',
      phone: '+919876543214',
      password: 'Admin@123',
      role: UserRole.admin,
    ),
  ];

  /// Tracks the currently logged-in user session (in-memory only).
  MockAccount? _currentUser;

  /// Returns all accounts (for display in staff lists, etc.)
  List<MockAccount> get all => List.unmodifiable(_accounts);

  /// Returns all accounts that are NOT patients (i.e. staff members).
  List<MockAccount> get staffMembers =>
      _accounts.where((a) => a.role != UserRole.patient).toList();

  /// Returns all staff members — alias used by admin screens.
  List<MockAccount> getAllStaff() => staffMembers;

  /// Returns the currently authenticated mock user, or null if no session.
  MockAccount? getCurrentUser() => _currentUser;

  /// Clears the current user session.
  void logout() {
    _currentUser = null;
  }

  /// Registers a new patient account.
  /// Throws if the email is already in use.
  void registerPatient({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) {
    if (_findByEmail(email) != null) {
      throw Exception('An account with this email already exists.');
    }
    _accounts.add(MockAccount(
      name: name,
      email: email,
      phone: phone,
      password: password,
      role: UserRole.patient,
    ));
  }

  /// Adds a new staff member account with the specified role.
  /// Throws if the email is already in use.
  void addStaffMember({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) {
    if (_findByEmail(email) != null) {
      throw Exception('An account with this email already exists.');
    }
    _accounts.add(MockAccount(
      name: name,
      email: email,
      phone: phone,
      password: password,
      role: role,
    ));
  }

  /// Looks up an account by email + password.
  /// Returns the account on success, sets currentUser, or throws a descriptive error.
  MockAccount login({required String email, required String password}) {
    final account = _findByEmail(email);
    if (account == null || account.password != password) {
      // Always throw the same message regardless of which field was wrong
      // to prevent email enumeration attacks (even in dev, good practice).
      throw Exception('Invalid email or password.');
    }
    _currentUser = account;
    return account;
  }

  MockAccount? _findByEmail(String email) {
    try {
      return _accounts.firstWhere(
        (a) => a.email.toLowerCase() == email.toLowerCase().trim(),
      );
    } catch (_) {
      return null;
    }
  }
}

// ---------------------------------------------------------------------------
// Token / session helpers (unchanged)
// ---------------------------------------------------------------------------

class AuthTokenResponse {
  final String accessToken;
  final String refreshToken;
  final String sessionId;
  final String userName;
  final String userEmail;

  const AuthTokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.sessionId,
    required this.userName,
    required this.userEmail,
  });
}

// ---------------------------------------------------------------------------
// AuthService
// ---------------------------------------------------------------------------

class AuthService {
  static const _refreshTokenKey = 'astha_refresh_token';
  static const _rememberMeKey = 'astha_remember_me';
  static const _biometricKey = 'astha_biometric_enabled';
  static const _sessionKey = 'astha_session_info';

  final LocalAuthentication _localAuth = LocalAuthentication();
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleInitialized = false;
  final Map<String, String> _otpStore = {};

  // ── Mock DB passthrough methods ──────────────────────────────────────────

  /// Registers a patient in the mock DB then returns a token response.
  Future<AuthTokenResponse> registerPatient({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final res = await ApiService.post('/auth/register', {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      });
      if (res['tokens'] != null && res['tokens']['accessToken'] != null) {
        ApiService.setAuthToken(res['tokens']['accessToken'].toString());
      }
    } catch (_) {}

    MockUserDatabase.instance.registerPatient(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );
    return _createMockResponse(email: email, role: UserRole.patient, name: name);
  }

  /// Adds a staff member to the mock DB then returns a token response.
  Future<AuthTokenResponse> addStaffMember({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    try {
      await ApiService.post('/staff', {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role.name.toUpperCase(),
      });
    } catch (_) {}

    MockUserDatabase.instance.addStaffMember(
      name: name,
      email: email,
      phone: phone,
      password: password,
      role: role,
    );
    return _createMockResponse(email: email, role: role, name: name);
  }

  /// Looks up credentials in the mock DB and returns an account with its role.
  Future<MockAccount> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return MockUserDatabase.instance.login(email: email, password: password);
  }

  /// Returns the currently authenticated mock user session, or null.
  MockAccount? getCurrentUser() => MockUserDatabase.instance.getCurrentUser();

  /// Clears the mock user session (call on logout).
  void logout() => MockUserDatabase.instance.logout();

  /// Returns all staff members from the mock DB.
  List<MockAccount> getAllStaff() => MockUserDatabase.instance.getAllStaff();


  Future<AuthTokenResponse> loginWithEmailPassword({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return _createMockResponse(email: email, role: role);
  }

  Future<void> _ensureGoogleInitialized() async {
    if (!_googleInitialized) {
      await _googleSignIn.initialize();
      _googleInitialized = true;
    }
  }

  Future<AuthTokenResponse> loginWithGoogle({
    required UserRole role,
  }) async {
    try {
      await _ensureGoogleInitialized();
      final googleUser = await _googleSignIn.authenticate(scopeHint: const ['email']);
      final email = googleUser.email;
      final name = googleUser.displayName ?? 'Google User';
      return _createMockResponse(email: email, role: role, name: name);
    } catch (error) {
      return _createMockResponse(email: 'google.user@astha.com', role: role, name: 'Google User');
    }
  }

  Future<String> sendMobileOtp(String mobile) async {
    await Future.delayed(const Duration(milliseconds: 500));
    const otp = '123456';
    _otpStore[mobile] = otp;
    return otp;
  }

  Future<AuthTokenResponse> verifyMobileOtp({
    required String mobile,
    required String otp,
    required UserRole role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final expected = _otpStore[mobile];
    if (expected != otp) {
      throw Exception('Invalid OTP entered.');
    }
    return _createMockResponse(email: '$mobile@astha.com', role: role, name: 'Mobile User');
  }

  Future<AuthTokenResponse> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return _createMockResponse(email: email, role: role, name: name);
  }

  Future<AuthTokenResponse> registerWithMobile({
    required String name,
    required String mobile,
    required String password,
    required UserRole role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return _createMockResponse(email: '$mobile@astha.com', role: role, name: name);
  }

  Future<void> sendPasswordReset({required String emailOrMobile}) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  Future<void> resetPassword({required String resetToken, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<bool> isBiometricAvailable() async {
    final deviceSupported = await _localAuth.isDeviceSupported();
    final canCheckBiometrics = await _localAuth.canCheckBiometrics;
    return deviceSupported || canCheckBiometrics;
  }

  Future<bool> authenticateBiometric() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Astha Diagnostic securely.',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> persistSession({
    required String refreshToken,
    required bool rememberMe,
    required String sessionId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setBool(_rememberMeKey, rememberMe);
    await prefs.setString(
        _sessionKey, jsonEncode({'sessionId': sessionId, 'refreshToken': refreshToken}));
  }

  Future<void> clearSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_rememberMeKey);
    await prefs.remove(_sessionKey);
  }

  Future<String?> loadSavedRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<bool> loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  Future<void> saveBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricKey, enabled);
  }

  Future<bool> loadBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricKey) ?? false;
  }

  Future<AuthTokenResponse> refreshSession(String refreshToken, UserRole role) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return AuthTokenResponse(
      accessToken: 'refreshed-access-$refreshToken',
      refreshToken: refreshToken,
      sessionId: 'session-${DateTime.now().millisecondsSinceEpoch}',
      userName: '${role.displayName} User',
      userEmail: 'refresh.${role.name}@astha.com',
    );
  }

  Future<void> logoutAllDevices() async {
    await clearSavedSession();
  }

  AuthTokenResponse _createMockResponse({
    required String email,
    required UserRole role,
    String? name,
  }) {
    final sessionId = '${role.name}-${DateTime.now().millisecondsSinceEpoch}';
    return AuthTokenResponse(
      accessToken: 'access-$sessionId',
      refreshToken: 'refresh-$sessionId',
      sessionId: sessionId,
      userName: name ?? role.displayName,
      userEmail: email,
    );
  }
}
