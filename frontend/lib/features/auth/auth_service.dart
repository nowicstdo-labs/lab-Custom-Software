import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_models.dart';
import '../../services/api_service.dart';
import '../../services/secure_storage_service.dart';

// ---------------------------------------------------------------------------
// Mock User Database (Used strictly for dev test credentials banner in debug)
// ---------------------------------------------------------------------------

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

class MockUserDatabase {
  MockUserDatabase._();
  static final MockUserDatabase instance = MockUserDatabase._();

  final List<MockAccount> _accounts = [
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
    MockAccount(
      name: 'Astha Diagnostic Admin',
      email: 'admin@asthadiagnostic.com',
      phone: '+919876543214',
      password: 'Admin@123',
      role: UserRole.admin,
    ),
  ];

  MockAccount? _currentUser;

  List<MockAccount> get all => List.unmodifiable(_accounts);
  List<MockAccount> get staffMembers =>
      _accounts.where((a) => a.role != UserRole.patient).toList();
  List<MockAccount> getAllStaff() => staffMembers;

  MockAccount? getCurrentUser() => _currentUser;

  void setCurrentUser(MockAccount account) {
    _currentUser = account;
    if (_findByEmail(account.email) == null) {
      _accounts.add(account);
    }
  }

  void logout() {
    _currentUser = null;
  }

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

  MockAccount login({required String email, required String password}) {
    final account = _findByEmail(email);
    if (account == null || account.password != password) {
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

UserRole parseUserRole(String roleStr) {
  final upper = roleStr.toUpperCase();
  if (upper == 'PATIENT') return UserRole.patient;
  if (upper == 'DOCTOR') return UserRole.doctor;
  if (upper == 'RECEPTIONIST') return UserRole.receptionist;
  if (upper == 'LAB_TECHNICIAN' || upper == 'LABTECHNICIAN' || upper == 'LAB_TECH') return UserRole.labTechnician;
  if (upper == 'ADMIN') return UserRole.admin;
  return UserRole.patient;
}

class AuthTokenResponse {
  final String accessToken;
  final String refreshToken;
  final String sessionId;
  final String userName;
  final String userEmail;
  final UserRole? userRole;

  const AuthTokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.sessionId,
    required this.userName,
    required this.userEmail,
    this.userRole,
  });
}

class AuthService {
  static const _biometricKey = 'astha_biometric_enabled';
  static const _rememberMeKey = 'astha_remember_me';

  final LocalAuthentication _localAuth = LocalAuthentication();
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleInitialized = false;

  /// Registers a patient via live API then returns token response.
  Future<AuthTokenResponse> registerPatient({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final res = await ApiService.post('/auth/register', {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
    });

    if (res['success'] == true && res['data'] != null) {
      final data = res['data'];
      final accessToken = data['accessToken'] as String? ?? '';
      final refreshToken = data['refreshToken'] as String? ?? '';
      final userData = data['user'] as Map<String, dynamic>? ?? {};

      ApiService.setAuthToken(accessToken);
      ApiService.refreshToken = refreshToken;

      final roleStr = userData['role'] as String? ?? 'PATIENT';
      final role = parseUserRole(roleStr);
      final userId = userData['id'] as String? ?? 'u-${DateTime.now().millisecondsSinceEpoch}';

      final user = AppUser(
        id: userId,
        name: name,
        email: email,
        mobile: phone,
        role: role,
      );

      await SecureStorageService.instance.saveAccessToken(accessToken);
      await SecureStorageService.instance.saveRefreshToken(refreshToken);
      await SecureStorageService.instance.saveUserSession(user);

      return AuthTokenResponse(
        accessToken: accessToken,
        refreshToken: refreshToken,
        sessionId: userId,
        userName: name,
        userEmail: email,
        userRole: role,
      );
    } else {
      throw Exception(res['message'] ?? 'Registration failed.');
    }
  }

  /// Adds a staff member via live API then returns a token response.
  Future<AuthTokenResponse> addStaffMember({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    try {
      final roleStr = role == UserRole.labTechnician ? 'LAB_TECHNICIAN' : role.name.toUpperCase();
      await ApiService.post('/staff', {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': roleStr,
      });
    } catch (_) {}

    try {
      MockUserDatabase.instance.addStaffMember(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );
    } catch (_) {}
    return _createMockResponse(email: email, role: role, name: name);
  }

  /// Authenticates user against Live API backend.
  Future<MockAccount> login({
    required String email,
    required String password,
  }) async {
    final res = await ApiService.post('/auth/login', {
      'email': email,
      'password': password,
    });

    if (res['success'] == true && res['data'] != null) {
      final data = res['data'];
      final userData = data['user'] as Map<String, dynamic>? ?? {};
      final accessToken = data['accessToken'] as String? ?? '';
      final refreshToken = data['refreshToken'] as String? ?? '';

      ApiService.setAuthToken(accessToken);
      ApiService.refreshToken = refreshToken;

      final roleStr = userData['role'] as String? ?? 'PATIENT';
      final userRole = parseUserRole(roleStr);
      final userId = userData['id'] as String? ?? 'u-${DateTime.now().millisecondsSinceEpoch}';
      final userName = userData['name'] as String? ?? email.split('@').first;
      final userPhone = userData['phone'] as String? ?? '';

      final user = AppUser(
        id: userId,
        name: userName,
        email: email,
        mobile: userPhone,
        role: userRole,
      );

      await SecureStorageService.instance.saveAccessToken(accessToken);
      await SecureStorageService.instance.saveRefreshToken(refreshToken);
      await SecureStorageService.instance.saveUserSession(user);

      final account = MockAccount(
        name: userName,
        email: email,
        phone: userPhone,
        password: password,
        role: userRole,
      );
      MockUserDatabase.instance.setCurrentUser(account);
      return account;
    } else {
      throw Exception(res['message'] ?? 'Invalid email or password credentials');
    }
  }

  MockAccount? getCurrentUser() => MockUserDatabase.instance.getCurrentUser();

  void logout() {
    MockUserDatabase.instance.logout();
    clearSavedSession();
  }

  List<MockAccount> getAllStaff() => MockUserDatabase.instance.getAllStaff();

  Future<AuthTokenResponse> loginWithEmailPassword({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final res = await ApiService.post('/auth/login', {
      'email': email,
      'password': password,
    });

    if (res['success'] == true && res['data'] != null) {
      final data = res['data'];
      final accessToken = data['accessToken'] as String? ?? '';
      final refreshToken = data['refreshToken'] as String? ?? '';
      final userData = data['user'] as Map<String, dynamic>? ?? {};

      ApiService.setAuthToken(accessToken);
      ApiService.refreshToken = refreshToken;

      final roleStr = userData['role'] as String? ?? role.name.toUpperCase();
      final actualRole = parseUserRole(roleStr);
      final userId = userData['id'] as String? ?? 'session-${DateTime.now().millisecondsSinceEpoch}';
      final userName = userData['name'] as String? ?? role.displayName;

      final user = AppUser(
        id: userId,
        name: userName,
        email: email,
        role: actualRole,
      );

      await SecureStorageService.instance.saveAccessToken(accessToken);
      await SecureStorageService.instance.saveRefreshToken(refreshToken);
      await SecureStorageService.instance.saveUserSession(user);

      return AuthTokenResponse(
        accessToken: accessToken,
        refreshToken: refreshToken,
        sessionId: userId,
        userName: userName,
        userEmail: email,
        userRole: actualRole,
      );
    } else {
      throw Exception(res['message'] ?? 'Invalid email or password credentials');
    }
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
    await _ensureGoogleInitialized();
    final googleUser = await _googleSignIn.authenticate(scopeHint: const ['email']);
    final auth = googleUser.authentication;
    final idToken = auth.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw Exception('Google Sign-In failed: could not obtain authentication token.');
    }

    final res = await ApiService.post('/auth/google', {'idToken': idToken});
    if (res['success'] == true && res['data'] != null) {
      final data = res['data'];
      final accessToken = data['accessToken'] as String? ?? '';
      final refreshToken = data['refreshToken'] as String? ?? '';
      final userData = data['user'] as Map<String, dynamic>? ?? {};

      ApiService.setAuthToken(accessToken);
      ApiService.refreshToken = refreshToken;

      final roleStr = userData['role'] as String? ?? 'PATIENT';
      final userRole = parseUserRole(roleStr);
      final userId = userData['id'] as String? ?? 'u-google-${DateTime.now().millisecondsSinceEpoch}';
      final email = userData['email'] as String? ?? googleUser.email;
      final name = userData['name'] as String? ?? googleUser.displayName ?? 'Google User';

      final user = AppUser(
        id: userId,
        name: name,
        email: email,
        role: userRole,
      );

      await SecureStorageService.instance.saveAccessToken(accessToken);
      await SecureStorageService.instance.saveRefreshToken(refreshToken);
      await SecureStorageService.instance.saveUserSession(user);

      return AuthTokenResponse(
        accessToken: accessToken,
        refreshToken: refreshToken,
        sessionId: userId,
        userName: name,
        userEmail: email,
        userRole: userRole,
      );
    } else {
      throw Exception(res['message'] ?? 'Google authentication failed on server.');
    }
  }

  Future<String> sendMobileOtp(String mobile) async {
    final res = await ApiService.post('/auth/forgot-password', {'emailOrPhone': mobile});
    if (res['success'] == true) {
      return res['otp'] as String? ?? 'OTP Sent';
    } else {
      throw Exception(res['message'] ?? 'Failed to send OTP.');
    }
  }

  Future<AuthTokenResponse> verifyMobileOtp({
    required String mobile,
    required String otp,
    required UserRole role,
  }) async {
    final res = await ApiService.post('/auth/reset-password', {
      'emailOrPhone': mobile,
      'otp': otp,
      'newPassword': 'Password@123',
    });
    if (res['success'] == true) {
      return loginWithEmailPassword(email: mobile, password: 'Password@123', role: role);
    } else {
      throw Exception(res['message'] ?? 'OTP verification failed.');
    }
  }

  Future<AuthTokenResponse> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    return registerPatient(name: name, email: email, phone: '', password: password);
  }

  Future<AuthTokenResponse> registerWithMobile({
    required String name,
    required String mobile,
    required String password,
    required UserRole role,
  }) async {
    return registerPatient(name: name, email: '$mobile@astha.com', phone: mobile, password: password);
  }

  Future<void> sendPasswordReset({required String emailOrMobile}) async {
    final res = await ApiService.post('/auth/forgot-password', {'emailOrPhone': emailOrMobile});
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Failed to send password reset code.');
    }
  }

  Future<void> resetPassword({required String resetToken, required String password}) async {
    final res = await ApiService.post('/auth/reset-password', {
      'emailOrPhone': resetToken,
      'otp': resetToken,
      'newPassword': password,
    });
    if (res['success'] != true) {
      throw Exception(res['message'] ?? 'Password reset failed.');
    }
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
    required String accessToken,
    required String refreshToken,
    required AppUser user,
    bool rememberMe = true,
  }) async {
    await SecureStorageService.instance.saveAccessToken(accessToken);
    await SecureStorageService.instance.saveRefreshToken(refreshToken);
    await SecureStorageService.instance.saveUserSession(user);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, rememberMe);
  }

  Future<void> clearSavedSession() async {
    await SecureStorageService.instance.clearAll();
    ApiService.accessToken = null;
    ApiService.refreshToken = null;
  }

  Future<String?> loadSavedAccessToken() async {
    return SecureStorageService.instance.getAccessToken();
  }

  Future<String?> loadSavedRefreshToken() async {
    return SecureStorageService.instance.getRefreshToken();
  }

  Future<AppUser?> loadSavedUserSession() async {
    return SecureStorageService.instance.getUserSession();
  }

  Future<bool> loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? true;
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
    ApiService.refreshToken = refreshToken;
    final refreshed = await ApiService.refreshAccessToken();
    if (refreshed && ApiService.accessToken != null) {
      final user = await loadSavedUserSession();
      return AuthTokenResponse(
        accessToken: ApiService.accessToken!,
        refreshToken: ApiService.refreshToken ?? refreshToken,
        sessionId: user?.id ?? 'session-restored',
        userName: user?.name ?? role.displayName,
        userEmail: user?.email ?? 'user@astha.com',
        userRole: user?.role ?? role,
      );
    }
    throw Exception('Session refresh failed');
  }

  Future<void> logoutAllDevices() async {
    try {
      final user = await loadSavedUserSession();
      if (user != null) {
        await ApiService.post('/auth/logout', {'userId': user.id});
      }
    } catch (_) {}
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
      userRole: role,
    );
  }
}

