import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/auth_models.dart';
import '../features/auth/auth_provider.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/otp_verification_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/reset_password_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/dashboard/screens/add_staff_screen.dart';
import '../features/dashboard/screens/admin_dashboard_screen.dart';
import '../features/dashboard/screens/audit_log_screen.dart';
import '../features/dashboard/screens/billing_screen.dart';
import '../features/dashboard/screens/consultation_screen.dart';
import '../features/dashboard/screens/doctor_dashboard_screen.dart';
import '../features/dashboard/screens/formula_management_screen.dart';
import '../features/dashboard/screens/global_search_screen.dart';
import '../features/dashboard/screens/notification_center_screen.dart';
import '../features/dashboard/screens/patient_dashboard_screen.dart';
import '../features/dashboard/screens/receptionist_dashboard_screen.dart';
import '../features/dashboard/screens/report_approval_screen.dart';
import '../features/dashboard/screens/report_builder_screen.dart';
import '../features/lab_technician/screens/assigned_tests_screen.dart';
import '../features/lab_technician/screens/completed_tests_screen.dart';
import '../features/lab_technician/screens/lab_technician_dashboard.dart';
import '../features/lab_technician/screens/result_entry_screen.dart';
import '../features/lab_technician/screens/sample_management_screen.dart';
import '../features/lab_technician/screens/sample_scanner_screen.dart';
import '../features/lab_technician/screens/technician_notifications_screen.dart';
import '../features/lab_technician/screens/technician_profile_screen.dart';
import '../features/lab_technician/screens/technician_report_preview_screen.dart';
import '../features/lab_technician/screens/test_processing_screen.dart';
import '../features/patient_management/patient_management_screen.dart';
import '../features/profile/screens/edit_profile_screen.dart';
import '../features/profile/screens/family_members_screen.dart';
import '../features/profile/screens/health_summary_screen.dart';
import '../features/profile/screens/help_support_screen.dart';
import '../features/profile/screens/my_bills_screen.dart';
import '../features/profile/screens/patient_profile_screen.dart';
import '../features/profile/screens/profile_info_screen.dart';
import '../features/profile/screens/settings_screen.dart';
import '../features/public/screens/a4_pdf_report_screen.dart';
import '../features/public/screens/about_screen.dart';
import '../features/public/screens/book_appointment_screen.dart';
import '../features/public/screens/book_test_screen.dart';
import '../features/public/screens/choose_section_screen.dart';
import '../features/public/screens/contact_screen.dart';
import '../features/public/screens/doctor_detail_screen.dart';
import '../features/public/screens/doctor_list_screen.dart';
import '../features/public/screens/faq_screen.dart';
import '../features/public/screens/health_packages_screen.dart';
import '../features/public/screens/home_screen.dart';
import '../features/public/screens/my_tests_screen.dart';
import '../features/public/screens/patient_appointments_screen.dart';
import '../features/public/screens/report_verification_screen.dart';
import '../features/public/screens/test_catalog_screen.dart';
import '../features/public/screens/test_details_screen.dart';

class AppRouter {
  AppRouter._();

  static late final GoRouter router;
  static bool _configured = false;

  static void configure(WidgetRef ref) {
    if (_configured) {
      return;
    }
    _configured = true;

    final authNotifier = ref.read(authProvider.notifier);

    router = GoRouter(
      initialLocation: '/splash',
      refreshListenable: _GoRouterRefreshStream(authNotifier.authStateStream),
      redirect: (context, state) {
        final auth = ref.read(authProvider);
        final location = state.matchedLocation;
        final isAuthRoute = location == '/login' ||
            location == '/register' ||
            location == '/forgot' ||
            location == '/reset-password' ||
            location == '/otp' ||
            location == '/splash';

        if (!auth.isAuthenticated && !isAuthRoute && !location.startsWith('/public')) {
          return '/login';
        }

        if (auth.isAuthenticated && isAuthRoute) {
          return auth.redirectPath;
        }

        // Role Access Guards
        if (auth.isAuthenticated && auth.user != null) {
          final role = auth.user!.role;
          if (location.startsWith('/admin') && role != UserRole.admin) {
            return auth.redirectPath;
          }
          if (location.startsWith('/lab-tech') && role != UserRole.labTechnician && role != UserRole.admin) {
            return auth.redirectPath;
          }
          if (location.startsWith('/doctor') && role != UserRole.doctor && role != UserRole.admin) {
            return auth.redirectPath;
          }
          if (location.startsWith('/receptionist') && role != UserRole.receptionist && role != UserRole.admin) {
            return auth.redirectPath;
          }
        }

        return null;
      },
      routes: [
        GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
        GoRoute(path: '/forgot', builder: (context, state) => const ForgotPasswordScreen()),
        GoRoute(path: '/reset-password', builder: (context, state) => const ResetPasswordScreen()),
        GoRoute(path: '/otp', builder: (context, state) => const OtpVerificationScreen()),

        // Public & Shared Patient Routes
        GoRoute(path: '/public', builder: (context, state) => const PublicHomeScreen()),
        GoRoute(path: '/public/about', builder: (context, state) => const AboutScreen()),
        GoRoute(path: '/public/packages', builder: (context, state) => const HealthPackagesScreen()),
        GoRoute(path: '/public/tests', builder: (context, state) => const TestCatalogScreen()),
        GoRoute(path: '/public/tests/details', builder: (context, state) => const TestDetailsScreen()),
        GoRoute(
          path: '/public/book-test',
          builder: (context, state) {
            final testId = state.uri.queryParameters['testId'];
            return BookTestScreen(initialTestId: testId);
          },
        ),
        GoRoute(
          path: '/public/book-appointment',
          builder: (context, state) {
            final doctorId = state.uri.queryParameters['doctorId'];
            final slot = state.uri.queryParameters['slot'];
            return BookAppointmentScreen(initialDoctorId: doctorId, initialSlotTime: slot);
          },
        ),
        GoRoute(path: '/public/appointments', builder: (context, state) => const PatientAppointmentsScreen()),
        GoRoute(path: '/public/my-tests', builder: (context, state) => const MyTestsScreen()),
        GoRoute(path: '/public/profile', builder: (context, state) => const PatientProfileScreen()),
        GoRoute(path: '/public/profile-info', builder: (context, state) => const ProfileInfoScreen()),
        GoRoute(path: '/public/edit-profile', builder: (context, state) => const EditProfileScreen()),
        GoRoute(path: '/public/family-members', builder: (context, state) => const FamilyMembersScreen()),
        GoRoute(path: '/public/health-summary', builder: (context, state) => const HealthSummaryScreen()),
        GoRoute(path: '/public/my-bills', builder: (context, state) => const MyBillsScreen()),
        GoRoute(path: '/public/help-support', builder: (context, state) => const HelpSupportScreen()),
        GoRoute(path: '/public/settings', builder: (context, state) => const SettingsScreen()),
        GoRoute(path: '/public/choose-section', builder: (context, state) => const ChooseSectionScreen()),
        GoRoute(path: '/public/doctors', builder: (context, state) => const DoctorListScreen()),
        GoRoute(
          path: '/public/doctors/:id',
          builder: (context, state) => DoctorDetailScreen(doctorId: state.pathParameters['id'] ?? 'd1'),
        ),
        GoRoute(path: '/public/contact', builder: (context, state) => const ContactScreen()),
        GoRoute(path: '/public/faq', builder: (context, state) => const FAQScreen()),

        // Printable Reports & QR Verification
        GoRoute(
          path: '/pdf-report',
          builder: (context, state) => A4PdfReportScreen(reportId: state.uri.queryParameters['reportId']),
        ),
        GoRoute(
          path: '/public/report-verification',
          builder: (context, state) => ReportVerificationScreen(reportId: state.uri.queryParameters['reportId']),
        ),

        // Shared Role Operations & Dashboards
        GoRoute(path: '/patient', pageBuilder: (context, state) => _fadeSlidePage(context, state, const PatientDashboardScreen())),
        GoRoute(path: '/patients', pageBuilder: (context, state) => _fadeSlidePage(context, state, const PatientManagementScreen())),
        GoRoute(path: '/receptionist', pageBuilder: (context, state) => _fadeSlidePage(context, state, const ReceptionistDashboardScreen())),
        GoRoute(path: '/lab-tech', pageBuilder: (context, state) => _fadeSlidePage(context, state, const LabTechnicianDashboardScreen())),
        GoRoute(path: '/lab-tech/assigned-tests', pageBuilder: (context, state) => _fadeSlidePage(context, state, const AssignedTestsScreen())),
        GoRoute(path: '/lab-tech/samples', pageBuilder: (context, state) => _fadeSlidePage(context, state, const SampleManagementScreen())),
        GoRoute(path: '/lab-tech/scanner', pageBuilder: (context, state) => _fadeSlidePage(context, state, const SampleScannerScreen())),
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
        GoRoute(path: '/report-builder', builder: (context, state) => const ReportBuilderScreen()),
        GoRoute(path: '/billing', builder: (context, state) => const BillingScreen()),
        GoRoute(path: '/notification-center', builder: (context, state) => const NotificationCenterScreen()),
        GoRoute(path: '/global-search', builder: (context, state) => const GlobalSearchScreen()),
        GoRoute(path: '/audit-log', builder: (context, state) => const AuditLogScreen()),

        // Doctor Routes
        GoRoute(path: '/doctor', pageBuilder: (context, state) => _fadeSlidePage(context, state, const DoctorDashboardScreen())),
        GoRoute(
          path: '/doctor/consultation',
          pageBuilder: (context, state) => _fadeSlidePage(
            context,
            state,
            ConsultationScreen(
              patientName: state.uri.queryParameters['patientName'] ?? 'Patient',
            ),
          ),
        ),

        // Admin Routes
        GoRoute(path: '/admin', pageBuilder: (context, state) => _fadeSlidePage(context, state, const AdminDashboardScreen())),
        GoRoute(path: '/admin/add-staff', pageBuilder: (context, state) => _fadeSlidePage(context, state, const AddStaffScreen())),
        GoRoute(path: '/admin/report-approval', pageBuilder: (context, state) => _fadeSlidePage(context, state, const ReportApprovalScreen())),
        GoRoute(path: '/admin/formulas', pageBuilder: (context, state) => _fadeSlidePage(context, state, const FormulaManagementScreen())),
      ],
    );
  }

  static CustomTransitionPage<void> _fadeSlidePage(BuildContext context, GoRouterState state, Widget child) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeAnimation = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
    );
  }
}

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    stream.listen((_) => notifyListeners());
  }
}
