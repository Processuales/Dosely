// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Dosely';

  @override
  String get tagline => 'Medication made clear';

  @override
  String get navHome => 'Home';

  @override
  String get navMyMeds => 'My Meds';

  @override
  String get navSchedule => 'Schedule';

  @override
  String get navProfile => 'Profile';

  @override
  String get navSettings => 'Settings';

  @override
  String get homeTitle => 'New Entry';

  @override
  String get homeScanLabel => 'Scan Medication Label';

  @override
  String get homeScanSubtitle => 'Align label within the frame';

  @override
  String get homeScanIngredients => 'Scan Ingredients';

  @override
  String get homeAddManually => 'Add Manually';

  @override
  String get homeRecentScans => 'Recent Scans';

  @override
  String get homeViewAll => 'View All';

  @override
  String get homeTryDemo => 'Try Demo';

  @override
  String get homeDemoSubtitle => 'See Dosely in action';

  @override
  String get readAloud => 'Read Aloud';

  @override
  String get statusSafe => 'Safe';

  @override
  String get statusCaution => 'Caution';

  @override
  String get statusConflict => 'Conflict';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get profileAge => 'Age';

  @override
  String get profileSex => 'Sex';

  @override
  String get profilePregnancy => 'Pregnancy Status';

  @override
  String get profileNotPregnant => 'Not Pregnant';

  @override
  String get profileMedicalProfile => 'Medical Profile';

  @override
  String get profileAllergies => 'Allergies';

  @override
  String get profileConditions => 'Conditions';

  @override
  String get profileEditFull => 'Edit Full Profile';

  @override
  String get profileEdit => 'Edit';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTextSize => 'Text Size';

  @override
  String get settingsTextNormal => 'Normal';

  @override
  String get settingsTextLarge => 'Large';

  @override
  String get settingsTextExtraLarge => 'Extra Large';

  @override
  String get settingsVoice => 'Voice Settings';

  @override
  String get settingsVoiceSlow => 'Slow';

  @override
  String get settingsVoiceNormal => 'Normal';

  @override
  String get settingsVoiceFast => 'Fast';

  @override
  String get settingsTestVoice => 'Test Voice';

  @override
  String get settingsSimpleMode => 'Simple Language Mode';

  @override
  String get settingsSimpleModeSubtitle => 'Explain like I\'m 12';

  @override
  String get settingsClearHistory => 'Clear Scan History';

  @override
  String get settingsAbout => 'About Dosely';

  @override
  String get settingsDisclaimer => 'Disclaimer & Data Sources';

  @override
  String get settingsPrivacy => 'Privacy Policy';

  @override
  String get medsTitle => 'My Medications';

  @override
  String get medsActive => 'Active Medications';

  @override
  String get medsExport => 'Export Summary (PDF)';

  @override
  String get medsShare => 'Share with Caregiver';

  @override
  String get medsLastScan => 'Last scan';

  @override
  String get medsToday => 'Today';

  @override
  String get medsYesterday => 'Yesterday';

  @override
  String medsDaysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get scheduleTitle => 'Your Plan for Today';

  @override
  String get scheduleReview => 'Review your scanned medication';

  @override
  String get scheduleReadPlan => 'Read Plan Aloud';

  @override
  String get scheduleDaily => 'Daily Schedule';

  @override
  String get scheduleMorning => 'Morning';

  @override
  String get scheduleMidday => 'Midday';

  @override
  String get scheduleEvening => 'Evening';

  @override
  String get scheduleNight => 'Night';

  @override
  String get scheduleNoMeds => 'No medications scheduled';

  @override
  String get scheduleTablet => 'tablet';

  @override
  String get scheduleWithFood => 'With food';

  @override
  String get scheduleAddAnother => 'Add Another Medication';

  @override
  String get scheduleHighConfidence => 'High Confidence';

  @override
  String get scheduleMediumConfidence => 'Medium Confidence';

  @override
  String get scheduleLowConfidence => 'Low Confidence';

  @override
  String get conflictTitle => 'Possible duplicate ingredient';

  @override
  String conflictDescription(String ingredient) {
    return 'You are already taking $ingredient in another medication. This may exceed safe daily limits.';
  }

  @override
  String get conflictViewDetails => 'View Details';

  @override
  String get sideEffectsTitle => 'Side Effects';

  @override
  String get sideEffectsCommon => 'Common Side Effects';

  @override
  String get sideEffectsSerious => 'Serious';

  @override
  String get sideEffectsHelp => 'Get Help';

  @override
  String get sideEffectsVeryCommon => 'Very Common';

  @override
  String get sideEffectsOccasional => 'Occasional';

  @override
  String get sideEffectsCallPharmacist => 'Call Pharmacist';

  @override
  String get sideEffectsEmergency => 'Emergency Guidance';

  @override
  String get disclaimerTitle => 'Important';

  @override
  String get disclaimerText =>
      'Dosely is an information assistant. We are NOT providing medical advice. Always consult your doctor or pharmacist before making medication decisions.';

  @override
  String get disclaimerAgree => 'I Understand';

  @override
  String get onboardingWelcome => 'Welcome to Dosely';

  @override
  String get onboardingChooseLanguage => 'Choose your language';

  @override
  String get onboardingChooseTextSize => 'Choose text size';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingGetStarted => 'Get Started';
}
