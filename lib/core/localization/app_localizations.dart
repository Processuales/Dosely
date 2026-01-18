import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list.
///
/// This class was MANUALLY CREATED as a workaround for missing Flutter CLI tools.
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  bool get isFrench => locale.languageCode == 'fr';

  String get appName => 'Dosely';
  String get back => isFrench ? 'Retour' : 'Back';
  String get speed => isFrench ? 'Vitesse' : 'Speed';
  String get tagline =>
      isFrench ? 'Médicament rendu clair' : 'Medication made clear';

  String get navHome => isFrench ? 'Accueil' : 'Home';
  String get navMyMeds => isFrench ? 'Mes Médicaments' : 'My Meds';
  String get navProfile => isFrench ? 'Profil' : 'Profile';
  String get navSettings => isFrench ? 'Paramètres' : 'Settings';
  String get navSchedule => isFrench ? 'Programme' : 'Schedule';

  String get homeTitle => isFrench ? 'Nouvelle Entrée' : 'New Entry';
  String get homeScanLabel =>
      isFrench ? 'Scanner l\'étiquette' : 'Scan Medication Label';
  String get homeScanSubtitle =>
      isFrench
          ? 'Aligner l\'étiquette dans le cadre'
          : 'Align label within the frame';
  String get homeScanIngredients =>
      isFrench ? 'Scanner les ingrédients' : 'Scan Ingredients';
  String get homeAddManually =>
      isFrench ? 'Ajouter Manuellement' : 'Add Manually';
  String get homeRecentScans => isFrench ? 'Scans Récents' : 'Recent Scans';
  String get homeViewAll => isFrench ? 'Voir Tout' : 'View All';
  String get homeTryDemo => isFrench ? 'Essayer la démo' : 'Try Demo';
  String get homeDemoSubtitle =>
      isFrench ? 'Voir Dosely en action' : 'See Dosely in action';

  String get readAloud => isFrench ? 'Lire à haute voix' : 'Read Aloud';

  String get statusSafe => isFrench ? 'Sûr' : 'Safe';
  String get statusCaution => isFrench ? 'Attention' : 'Caution';
  String get statusConflict => isFrench ? 'Conflit' : 'Conflict';

  String get profileTitle => isFrench ? 'Mon Profil' : 'My Profile';
  String get profileAge => isFrench ? 'Âge' : 'Age';
  String get profileSex => isFrench ? 'Sexe' : 'Sex';
  String get profilePregnancy => isFrench ? 'Grossesse' : 'Pregnancy Status';
  String get profileNotPregnant => isFrench ? 'Pas Enceinte' : 'Not Pregnant';
  String get profileMedicalProfile =>
      isFrench ? 'Profil Médical' : 'Medical Profile';
  String get profileAllergies => isFrench ? 'Allergies' : 'Allergies';
  String get profileConditions => isFrench ? 'Conditions' : 'Conditions';
  String get profileEditFull =>
      isFrench ? 'Modifier le profil complet' : 'Edit Full Profile';
  String get profileEdit => isFrench ? 'Modifier' : 'Edit';

  String get settingsTitle => isFrench ? 'Paramètres' : 'Settings';
  String get settingsLanguage => isFrench ? 'Langue' : 'Language';
  String get settingsTextSize => isFrench ? 'Taille du texte' : 'Text Size';
  String get settingsTextNormal => isFrench ? 'Normal' : 'Normal';
  String get settingsTextLarge => isFrench ? 'Grand' : 'Large';
  String get settingsTextExtraLarge => isFrench ? 'Très Grand' : 'Extra Large';
  String get settingsVoice => isFrench ? 'Paramètres Vocaux' : 'Voice Settings';
  String get settingsVoiceSlow => isFrench ? 'Lent' : 'Slow';
  String get settingsVoiceNormal => isFrench ? 'Normal' : 'Normal';
  String get settingsVoiceFast => isFrench ? 'Rapide' : 'Fast';
  String get settingsTestVoice => isFrench ? 'Tester la voix' : 'Test Voice';
  String get settingsSimpleMode =>
      isFrench ? 'Mode Langage Simple' : 'Simple Language Mode';
  String get settingsSimpleModeSubtitle =>
      isFrench ? 'Expliquez comme si j\'avais 12 ans' : "Explain like I'm 12";
  String get settingsClearHistory =>
      isFrench ? 'Effacer l\'historique' : 'Clear Scan History';
  String get settingsAbout => isFrench ? 'À propos de Dosely' : 'About Dosely';
  String get settingsDisclaimer =>
      isFrench
          ? 'Avertissement et sources de données'
          : 'Disclaimer & Data Sources';
  String get settingsPrivacy =>
      isFrench ? 'Politique de confidentialité' : 'Privacy Policy';

  String get medsTitle => isFrench ? 'Mes Médicaments' : 'My Medications';
  String get medsActive =>
      isFrench ? 'Médicaments Actifs' : 'Active Medications';
  String get medsExport =>
      isFrench ? 'Exporter le résumé (PDF)' : 'Export Summary (PDF)';
  String get medsShare =>
      isFrench ? 'Partager avec un soignant' : 'Share with Caregiver';
  String get medsLastScan => isFrench ? 'Dernier scan' : 'Last scan';
  String get medsToday => isFrench ? 'Aujourd\'hui' : 'Today';
  String get medsYesterday => isFrench ? 'Hier' : 'Yesterday';

  String medsDaysAgo(int days) =>
      isFrench ? 'Il y a $days jours' : '$days days ago';

  String get scheduleTitle =>
      isFrench ? 'Votre plan pour aujourd\'hui' : 'Your Plan for Today';
  String get scheduleReview =>
      isFrench
          ? 'Vérifiez votre médicament scanné'
          : 'Review your scanned medication';
  String get scheduleReadPlan =>
      isFrench ? 'Lire le plan à haute voix' : 'Read Plan Aloud';
  String get scheduleDaily =>
      isFrench ? 'Programme quotidien' : 'Daily Schedule';
  String get scheduleMorning => isFrench ? 'Matin' : 'Morning';
  String get scheduleMidday => isFrench ? 'Midi' : 'Midday';
  String get scheduleEvening => isFrench ? 'Soir' : 'Evening';
  String get scheduleNight => isFrench ? 'Nuit' : 'Night';
  String get scheduleNoMeds =>
      isFrench ? 'Aucun médicament prévu' : 'No medications scheduled';
  String get scheduleTablet => isFrench ? 'comprimé' : 'tablet';
  String get scheduleWithFood =>
      isFrench ? 'Avec de la nourriture' : 'With food';
  String get scheduleAddAnother =>
      isFrench ? 'Ajouter un autre médicament' : 'Add Another Medication';
  String get scheduleHighConfidence =>
      isFrench ? 'Confiance Élevée' : 'High Confidence';
  String get scheduleMediumConfidence =>
      isFrench ? 'Confiance Moyenne' : 'Medium Confidence';
  String get scheduleLowConfidence =>
      isFrench ? 'Faible Confiance' : 'Low Confidence';

  String get conflictTitle =>
      isFrench
          ? 'Ingrédient dupliqué possible'
          : 'Possible duplicate ingredient';
  String conflictDescription(String ingredient) =>
      isFrench
          ? 'Vous prenez déjà $ingredient dans un autre médicament. Cela peut dépasser les limites quotidiennes de sécurité.'
          : 'You are already taking $ingredient in another medication. This may exceed safe daily limits.';
  String get conflictViewDetails =>
      isFrench ? 'Voir les détails' : 'View Details';

  String get sideEffectsTitle =>
      isFrench ? 'Effets Secondaires' : 'Side Effects';
  String get sideEffectsCommon =>
      isFrench ? 'Effets Secondaires Courants' : 'Common Side Effects';
  String get sideEffectsSerious => isFrench ? 'Grave' : 'Serious';
  String get sideEffectsHelp => isFrench ? 'Obtenir de l\'aide' : 'Get Help';
  String get sideEffectsVeryCommon => isFrench ? 'Très Courant' : 'Very Common';
  String get sideEffectsOccasional => isFrench ? 'Occasionnel' : 'Occasional';
  String get sideEffectsCallPharmacist =>
      isFrench ? 'Appeler le pharmacien' : 'Call Pharmacist';
  String get sideEffectsEmergency =>
      isFrench ? 'Conseils d\'urgence' : 'Emergency Guidance';

  String get disclaimerTitle => isFrench ? 'Important' : 'Important';
  String get disclaimerText =>
      isFrench
          ? 'Dosely est un assistant d\'information. Nous ne fournissons PAS de conseils médicaux. Consultez toujours votre médecin ou votre pharmacien avant de prendre des décisions concernant les médicaments.'
          : 'Dosely is an information assistant. We are NOT providing medical advice. Always consult your doctor or pharmacist before making medication decisions.';
  String get disclaimerAgree => isFrench ? 'Je Comprends' : 'I Understand';

  String get onboardingWelcome =>
      isFrench ? 'Bienvenue sur Dosely' : 'Welcome to Dosely';
  String get onboardingChooseLanguage =>
      isFrench ? 'Choisissez votre langue' : 'Choose your language';
  String get onboardingChooseTextSize =>
      isFrench ? 'Choisissez la taille du texte' : 'Choose text size';
  String get onboardingContinue => isFrench ? 'Continuer' : 'Continue';
  String get onboardingSkip => isFrench ? 'Sauter' : 'Skip';
  String get onboardingGetStarted => isFrench ? 'Commencer' : 'Get Started';

  // Profile Basics
  String get onboardingTellUs =>
      isFrench ? 'Parlez-nous de vous' : 'Tell us about you';
  String get onboardingNameLabel => isFrench ? 'Nom' : 'Name';
  String get onboardingNameHint =>
      isFrench
          ? 'Comment devons-nous vous appeler ?'
          : 'What should we call you?';
  String get onboardingAgeLabel => isFrench ? 'Âge' : 'Age';
  String get onboardingPronounsLabel => isFrench ? 'Pronoms' : 'Pronouns';
  String get onboardingPronounsHint =>
      isFrench ? 'ex. Elle/La' : 'e.g. She/Her';
  String get onboardingSexLabel => isFrench ? 'Sexe' : 'Sex';
  String get onboardingPregnantLabel =>
      isFrench ? 'Êtes-vous enceinte ?' : 'Are you pregnant?';

  // Medical Profile
  String get onboardingMedicalTitle =>
      isFrench ? 'Profil Médical' : 'Medical Profile';
  String get onboardingMedicalDesc =>
      isFrench
          ? 'Veuillez énumérer vos allergies et conditions médicales connues. Nous analyserons cela pour personnaliser vos alertes de sécurité.'
          : 'Please list any known allergies and medical conditions. We will analyze this to personalize your safety alerts.';
  String get onboardingMedicalHint =>
      isFrench
          ? 'ex. Allergie aux arachides, Asthme, Diabète de type 2...'
          : 'e.g., Peanut allergy, Asthma, Diabetes type 2...';
  String get onboardingAiAnalysis =>
      isFrench
          ? 'L\'IA analysera vos notes pour identifier automatiquement les allergies et les conditions.'
          : 'AI will analyze your notes to identify allergies and conditions automatically.';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
