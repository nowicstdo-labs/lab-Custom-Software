enum UserRole {
  patient,
  receptionist,
  labTechnician,
  doctor,
  admin,
}

enum AuthMethod {
  emailPassword,
  mobileOtp,
  google,
  biometric,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.patient:
        return 'Patient';
      case UserRole.receptionist:
        return 'Receptionist';
      case UserRole.labTechnician:
        return 'Lab Technician';
      case UserRole.doctor:
        return 'Doctor';
      case UserRole.admin:
        return 'Admin';
    }
  }

  String get dashboardRoute {
    switch (this) {
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

class AppUser {
  final String id;
  final String name;
  final String email;
  final String? mobile;
  final UserRole role;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.mobile,
    required this.role,
  });
}

class AuthSession {
  final String id;
  final String deviceName;
  final String refreshToken;
  final DateTime issuedAt;
  final bool active;

  const AuthSession({
    required this.id,
    required this.deviceName,
    required this.refreshToken,
    required this.issuedAt,
    this.active = true,
  });
}

class AuthState {
  final bool isAuthenticated;
  final AppUser? user;
  final AuthMethod? authMethod;
  final String? accessToken;
  final String? refreshToken;
  final bool rememberMe;
  final bool biometricEnabled;
  final bool otpSent;
  final String? otpDestination;
  final List<AuthSession> sessions;

  const AuthState({
    required this.isAuthenticated,
    this.user,
    this.authMethod,
    this.accessToken,
    this.refreshToken,
    this.rememberMe = false,
    this.biometricEnabled = false,
    this.otpSent = false,
    this.otpDestination,
    this.sessions = const [],
  });

  String get redirectPath {
    if (!isAuthenticated || user == null) {
      return '/login';
    }
    return user!.role.dashboardRoute;
  }

  AuthState copyWith({
    bool? isAuthenticated,
    AppUser? user,
    AuthMethod? authMethod,
    String? accessToken,
    String? refreshToken,
    bool? rememberMe,
    bool? biometricEnabled,
    bool? otpSent,
    String? otpDestination,
    List<AuthSession>? sessions,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      authMethod: authMethod ?? this.authMethod,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      rememberMe: rememberMe ?? this.rememberMe,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      otpSent: otpSent ?? this.otpSent,
      otpDestination: otpDestination ?? this.otpDestination,
      sessions: sessions ?? this.sessions,
    );
  }
}
