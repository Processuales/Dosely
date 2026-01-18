import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'Dosely'**
  String get appName;

  /// App tagline
  ///
  /// In en, this message translates to:
  /// **'Medication made clear'**
  String get tagline;

  /// Bottom navigation: Home tab
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom navigation: My Medications tab
  ///
  /// In en, this message translates to:
  /// **'My Meds'**
  String get navMyMeds;

  /// Bottom navigation: Schedule tab
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get navSchedule;

  /// Bottom navigation: Profile tab
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Bottom navigation: Settings tab
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Home screen main title
  ///
  /// In en, this message translates to:
  /// **'New Entry'**
  String get homeTitle;

  /// Primary scan button text
  ///
  /// In en, this message translates to:
  /// **'Scan Medication Label'**
  String get homeScanLabel;

  /// Scan button subtitle
  ///
  /// In en, this message translates to:
  /// **'Align label within the frame'**
  String get homeScanSubtitle;

  /// Secondary action: scan ingredients
  ///
  /// In en, this message translates to:
  /// **'Scan Ingredients'**
  String get homeScanIngredients;

  /// Secondary action: manual entry
  ///
  /// In en, this message translates to:
  /// **'Add Manually'**
  String get homeAddManually;

  /// Section title for recent scans
  ///
  /// In en, this message translates to:
  /// **'Recent Scans'**
  String get homeRecentScans;

  /// Link to view all scans
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get homeViewAll;

  /// Demo button for judges
  ///
  /// In en, this message translates to:
  /// **'Try Demo'**
  String get homeTryDemo;

  /// Demo button subtitle
  ///
  /// In en, this message translates to:
  /// **'See Dosely in action'**
  String get homeDemoSubtitle;

  /// TTS button text
  ///
  /// In en, this message translates to:
  /// **'Read Aloud'**
  String get readAloud;

  /// Medication status: safe
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get statusSafe;

  /// Medication status: caution
  ///
  /// In en, this message translates to:
  /// **'Caution'**
  String get statusCaution;

  /// Medication status: conflict
  ///
  /// In en, this message translates to:
  /// **'Conflict'**
  String get statusConflict;

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileTitle;

  /// Profile: age label
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get profileAge;

  /// Profile: sex label
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get profileSex;

  /// Profile: pregnancy status label
  ///
  /// In en, this message translates to:
  /// **'Pregnancy Status'**
  String get profilePregnancy;

  /// Profile: not pregnant option
  ///
  /// In en, this message translates to:
  /// **'Not Pregnant'**
  String get profileNotPregnant;

  /// Profile section title
  ///
  /// In en, this message translates to:
  /// **'Medical Profile'**
  String get profileMedicalProfile;

  /// Allergies section label
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get profileAllergies;

  /// Medical conditions section label
  ///
  /// In en, this message translates to:
  /// **'Conditions'**
  String get profileConditions;

  /// Edit profile button
  ///
  /// In en, this message translates to:
  /// **'Edit Full Profile'**
  String get profileEditFull;

  /// Generic edit button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get profileEdit;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Text size setting label
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get settingsTextSize;

  /// Text size: normal
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get settingsTextNormal;

  /// Text size: large
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get settingsTextLarge;

  /// Text size: extra large
  ///
  /// In en, this message translates to:
  /// **'Extra Large'**
  String get settingsTextExtraLarge;

  /// Voice settings section
  ///
  /// In en, this message translates to:
  /// **'Voice Settings'**
  String get settingsVoice;

  /// Voice speed: slow
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get settingsVoiceSlow;

  /// Voice speed: normal
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get settingsVoiceNormal;

  /// Voice speed: fast
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get settingsVoiceFast;

  /// Button to test TTS
  ///
  /// In en, this message translates to:
  /// **'Test Voice'**
  String get settingsTestVoice;

  /// Simple language toggle
  ///
  /// In en, this message translates to:
  /// **'Simple Language Mode'**
  String get settingsSimpleMode;

  /// Simple mode explanation
  ///
  /// In en, this message translates to:
  /// **'Explain like I\'m 12'**
  String get settingsSimpleModeSubtitle;

  /// Button to clear history
  ///
  /// In en, this message translates to:
  /// **'Clear Scan History'**
  String get settingsClearHistory;

  /// About link
  ///
  /// In en, this message translates to:
  /// **'About Dosely'**
  String get settingsAbout;

  /// Disclaimer link
  ///
  /// In en, this message translates to:
  /// **'Disclaimer & Data Sources'**
  String get settingsDisclaimer;

  /// Privacy policy link
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacy;

  /// Medication list screen title
  ///
  /// In en, this message translates to:
  /// **'My Medications'**
  String get medsTitle;

  /// Active medications section
  ///
  /// In en, this message translates to:
  /// **'Active Medications'**
  String get medsActive;

  /// Export button
  ///
  /// In en, this message translates to:
  /// **'Export Summary (PDF)'**
  String get medsExport;

  /// Share button
  ///
  /// In en, this message translates to:
  /// **'Share with Caregiver'**
  String get medsShare;

  /// Last scan label
  ///
  /// In en, this message translates to:
  /// **'Last scan'**
  String get medsLastScan;

  /// Today label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get medsToday;

  /// Yesterday label
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get medsYesterday;

  /// Days ago label
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String medsDaysAgo(int days);

  /// Schedule screen title
  ///
  /// In en, this message translates to:
  /// **'Your Plan for Today'**
  String get scheduleTitle;

  /// Schedule subtitle
  ///
  /// In en, this message translates to:
  /// **'Review your scanned medication'**
  String get scheduleReview;

  /// TTS button for schedule
  ///
  /// In en, this message translates to:
  /// **'Read Plan Aloud'**
  String get scheduleReadPlan;

  /// Daily schedule section
  ///
  /// In en, this message translates to:
  /// **'Daily Schedule'**
  String get scheduleDaily;

  /// Morning time slot
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get scheduleMorning;

  /// Midday time slot
  ///
  /// In en, this message translates to:
  /// **'Midday'**
  String get scheduleMidday;

  /// Evening time slot
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get scheduleEvening;

  /// Night time slot
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get scheduleNight;

  /// Empty time slot message
  ///
  /// In en, this message translates to:
  /// **'No medications scheduled'**
  String get scheduleNoMeds;

  /// Tablet form
  ///
  /// In en, this message translates to:
  /// **'tablet'**
  String get scheduleTablet;

  /// Take with food instruction
  ///
  /// In en, this message translates to:
  /// **'With food'**
  String get scheduleWithFood;

  /// Add medication button
  ///
  /// In en, this message translates to:
  /// **'Add Another Medication'**
  String get scheduleAddAnother;

  /// Confidence level: high
  ///
  /// In en, this message translates to:
  /// **'High Confidence'**
  String get scheduleHighConfidence;

  /// Confidence level: medium
  ///
  /// In en, this message translates to:
  /// **'Medium Confidence'**
  String get scheduleMediumConfidence;

  /// Confidence level: low
  ///
  /// In en, this message translates to:
  /// **'Low Confidence'**
  String get scheduleLowConfidence;

  /// Conflict alert title
  ///
  /// In en, this message translates to:
  /// **'Possible duplicate ingredient'**
  String get conflictTitle;

  /// Conflict description with ingredient
  ///
  /// In en, this message translates to:
  /// **'You are already taking {ingredient} in another medication. This may exceed safe daily limits.'**
  String conflictDescription(String ingredient);

  /// View conflict details button
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get conflictViewDetails;

  /// Side effects screen title
  ///
  /// In en, this message translates to:
  /// **'Side Effects'**
  String get sideEffectsTitle;

  /// Common side effects tab
  ///
  /// In en, this message translates to:
  /// **'Common Side Effects'**
  String get sideEffectsCommon;

  /// Serious side effects tab
  ///
  /// In en, this message translates to:
  /// **'Serious'**
  String get sideEffectsSerious;

  /// Get help tab
  ///
  /// In en, this message translates to:
  /// **'Get Help'**
  String get sideEffectsHelp;

  /// Frequency: very common
  ///
  /// In en, this message translates to:
  /// **'Very Common'**
  String get sideEffectsVeryCommon;

  /// Frequency: occasional
  ///
  /// In en, this message translates to:
  /// **'Occasional'**
  String get sideEffectsOccasional;

  /// Call pharmacist button
  ///
  /// In en, this message translates to:
  /// **'Call Pharmacist'**
  String get sideEffectsCallPharmacist;

  /// Emergency button
  ///
  /// In en, this message translates to:
  /// **'Emergency Guidance'**
  String get sideEffectsEmergency;

  /// Disclaimer title
  ///
  /// In en, this message translates to:
  /// **'Important'**
  String get disclaimerTitle;

  /// Safety disclaimer
  ///
  /// In en, this message translates to:
  /// **'Dosely is an information assistant. We are NOT providing medical advice. Always consult your doctor or pharmacist before making medication decisions.'**
  String get disclaimerText;

  /// Disclaimer accept button
  ///
  /// In en, this message translates to:
  /// **'I Understand'**
  String get disclaimerAgree;

  /// Onboarding welcome
  ///
  /// In en, this message translates to:
  /// **'Welcome to Dosely'**
  String get onboardingWelcome;

  /// Language selection prompt
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get onboardingChooseLanguage;

  /// Text size selection prompt
  ///
  /// In en, this message translates to:
  /// **'Choose text size'**
  String get onboardingChooseTextSize;

  /// Continue button
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// Skip button
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// Final onboarding button
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;
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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
