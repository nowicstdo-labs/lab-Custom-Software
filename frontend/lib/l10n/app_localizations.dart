import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
    Locale('hi')
  ];

  /// No description provided for @welcome_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Astha Diagnostic'**
  String get welcome_title;

  /// No description provided for @welcome_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Premium diagnostic management for modern healthcare. Access lab reports, book tests, and consult with doctors.'**
  String get welcome_subtitle;

  /// No description provided for @create_account_btn.
  ///
  /// In en, this message translates to:
  /// **'Create an Account'**
  String get create_account_btn;

  /// No description provided for @login_btn.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login_btn;

  /// No description provided for @select_language_title.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get select_language_title;

  /// No description provided for @done_btn.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done_btn;

  /// No description provided for @welcome_back_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcome_back_title;

  /// No description provided for @login_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Login to access your diagnostic dashboard'**
  String get login_subtitle;

  /// No description provided for @login_with_email_tab.
  ///
  /// In en, this message translates to:
  /// **'Login with Email'**
  String get login_with_email_tab;

  /// No description provided for @login_with_mobile_tab.
  ///
  /// In en, this message translates to:
  /// **'Login with Mobile'**
  String get login_with_mobile_tab;

  /// No description provided for @email_label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email_label;

  /// No description provided for @email_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get email_hint;

  /// No description provided for @password_label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password_label;

  /// No description provided for @password_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get password_hint;

  /// No description provided for @phone_label.
  ///
  /// In en, this message translates to:
  /// **'Phone No'**
  String get phone_label;

  /// No description provided for @phone_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get phone_hint;

  /// No description provided for @otp_label.
  ///
  /// In en, this message translates to:
  /// **'OTP code'**
  String get otp_label;

  /// No description provided for @otp_hint.
  ///
  /// In en, this message translates to:
  /// **'123456'**
  String get otp_hint;

  /// No description provided for @select_role_label.
  ///
  /// In en, this message translates to:
  /// **'Select Role'**
  String get select_role_label;

  /// No description provided for @remember_me_checkbox.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get remember_me_checkbox;

  /// No description provided for @forgot_password_btn.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgot_password_btn;

  /// No description provided for @or_login_with.
  ///
  /// In en, this message translates to:
  /// **'Or login with'**
  String get or_login_with;

  /// No description provided for @biometric_login_btn.
  ///
  /// In en, this message translates to:
  /// **'Biometric Login'**
  String get biometric_login_btn;

  /// No description provided for @dont_have_account_text.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an Account? '**
  String get dont_have_account_text;

  /// No description provided for @sign_up_btn.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get sign_up_btn;

  /// No description provided for @language_label.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language_label;

  /// No description provided for @sign_up_title.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get sign_up_title;

  /// No description provided for @phone_register_hint.
  ///
  /// In en, this message translates to:
  /// **'+91 98765 43210'**
  String get phone_register_hint;

  /// No description provided for @confirm_password_label.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirm_password_label;

  /// No description provided for @confirm_password_hint.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirm_password_hint;

  /// No description provided for @already_have_account_text.
  ///
  /// In en, this message translates to:
  /// **'Already have an Account? '**
  String get already_have_account_text;

  /// No description provided for @email_tab.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email_tab;

  /// No description provided for @mobile_tab.
  ///
  /// In en, this message translates to:
  /// **'Mobile OTP'**
  String get mobile_tab;

  /// No description provided for @continue_google.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continue_google;

  /// No description provided for @use_biometric.
  ///
  /// In en, this message translates to:
  /// **'Use biometric login'**
  String get use_biometric;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @verify_otp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verify_otp;

  /// No description provided for @send_otp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get send_otp;

  /// No description provided for @email_address_label.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get email_address_label;

  /// No description provided for @mobile_number_label.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get mobile_number_label;

  /// No description provided for @mobile_number_hint.
  ///
  /// In en, this message translates to:
  /// **'+91 98765 43210'**
  String get mobile_number_hint;

  /// No description provided for @nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// No description provided for @nav_tests.
  ///
  /// In en, this message translates to:
  /// **'Tests'**
  String get nav_tests;

  /// No description provided for @nav_reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get nav_reports;

  /// No description provided for @nav_appointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get nav_appointments;

  /// No description provided for @nav_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get nav_profile;

  /// No description provided for @home_greeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, Welcome!'**
  String get home_greeting;

  /// No description provided for @home_search_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search diagnostic tests, packages...'**
  String get home_search_placeholder;

  /// No description provided for @home_quick_actions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get home_quick_actions;

  /// No description provided for @home_book_test.
  ///
  /// In en, this message translates to:
  /// **'Book a Test'**
  String get home_book_test;

  /// No description provided for @home_my_reports.
  ///
  /// In en, this message translates to:
  /// **'My Reports'**
  String get home_my_reports;

  /// No description provided for @home_doctor_consult.
  ///
  /// In en, this message translates to:
  /// **'Doctor Consult'**
  String get home_doctor_consult;

  /// No description provided for @home_health_packages.
  ///
  /// In en, this message translates to:
  /// **'Health Packages'**
  String get home_health_packages;

  /// No description provided for @home_upcoming_appointments.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Appointments'**
  String get home_upcoming_appointments;

  /// No description provided for @home_recent_reports.
  ///
  /// In en, this message translates to:
  /// **'Recent Reports'**
  String get home_recent_reports;

  /// No description provided for @doctor_dashboard_title.
  ///
  /// In en, this message translates to:
  /// **'Doctor Dashboard'**
  String get doctor_dashboard_title;

  /// No description provided for @doctor_patients.
  ///
  /// In en, this message translates to:
  /// **'Patient List'**
  String get doctor_patients;

  /// No description provided for @doctor_today_appointments.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Appointments'**
  String get doctor_today_appointments;

  /// No description provided for @doctor_prescriptions.
  ///
  /// In en, this message translates to:
  /// **'Prescriptions'**
  String get doctor_prescriptions;

  /// No description provided for @test_catalog_title.
  ///
  /// In en, this message translates to:
  /// **'Diagnostic Test Catalog'**
  String get test_catalog_title;

  /// No description provided for @test_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search by test name or category...'**
  String get test_search_hint;

  /// No description provided for @test_categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get test_categories;

  /// No description provided for @test_instructions.
  ///
  /// In en, this message translates to:
  /// **'Test Instructions'**
  String get test_instructions;

  /// No description provided for @test_price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get test_price;

  /// No description provided for @test_book_now.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get test_book_now;

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profile_title;

  /// No description provided for @profile_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profile_edit;

  /// No description provided for @profile_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profile_settings;

  /// No description provided for @profile_security.
  ///
  /// In en, this message translates to:
  /// **'Security & Privacy'**
  String get profile_security;

  /// No description provided for @profile_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profile_logout;

  /// No description provided for @profile_logout_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get profile_logout_confirm;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language Preference'**
  String get settings_language;

  /// No description provided for @settings_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settings_notifications;

  /// No description provided for @settings_about.
  ///
  /// In en, this message translates to:
  /// **'About Application'**
  String get settings_about;

  /// No description provided for @btn_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btn_cancel;

  /// No description provided for @btn_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get btn_confirm;

  /// No description provided for @btn_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get btn_retry;

  /// No description provided for @btn_save.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get btn_save;

  /// No description provided for @state_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get state_loading;

  /// No description provided for @state_empty.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get state_empty;

  /// No description provided for @state_error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get state_error;

  /// No description provided for @err_no_internet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get err_no_internet;

  /// No description provided for @err_timeout.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to server. Please try again.'**
  String get err_timeout;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
