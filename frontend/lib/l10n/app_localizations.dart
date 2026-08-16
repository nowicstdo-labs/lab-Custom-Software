import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ur.dart';

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
    Locale('hi'),
    Locale('ur')
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
      <String>['bn', 'en', 'hi', 'ur'].contains(locale.languageCode);

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
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
