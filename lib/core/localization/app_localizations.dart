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
/// Updated to support Dynamic AI Translation.
class AppLocalizations {
  final Locale locale;
  final Map<String, String>? _dynamicMap;

  AppLocalizations(this.locale, [this._dynamicMap]);

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

  /// Helper for dynamic lookup
  String _t(String key, String Function() defaultGetter) {
    if (_dynamicMap != null && _dynamicMap!.containsKey(key)) {
      return _dynamicMap![key] ?? defaultGetter();
    }
    return defaultGetter();
  }

  // --- GENERAL ---
  String get appName => _t('appName', () => 'Dosely');
  String get back => _t('back', () => isFrench ? 'Retour' : 'Back');
  String get speed => _t('speed', () => isFrench ? 'Vitesse' : 'Speed');
  String get tagline => _t(
    'tagline',
    () => isFrench ? 'Médicament rendu clair' : 'Medication made clear',
  );

  // --- NAVIGATION ---
  String get navHome => _t('navHome', () => isFrench ? 'Accueil' : 'Home');
  String get navMyMeds =>
      _t('navMyMeds', () => isFrench ? 'Mes Médicaments' : 'My Meds');
  String get navProfile =>
      _t('navProfile', () => isFrench ? 'Profil' : 'Profile');
  String get navSettings =>
      _t('navSettings', () => isFrench ? 'Paramètres' : 'Settings');
  String get navSchedule =>
      _t('navSchedule', () => isFrench ? 'Programme' : 'Schedule');

  // --- HOME SCREEN ---
  String get homeTitle =>
      _t('homeTitle', () => isFrench ? 'Nouvelle Entrée' : 'New Entry');
  String get homeScanLabel => _t(
    'homeScanLabel',
    () => isFrench ? 'Scanner l\'étiquette' : 'Scan Medication Label',
  );
  String get homeScanSubtitle => _t(
    'homeScanSubtitle',
    () =>
        isFrench
            ? 'Aligner l\'étiquette dans le cadre'
            : 'Align label within the frame',
  );
  String get homeScanIngredients => _t(
    'homeScanIngredients',
    () => isFrench ? 'Scanner les ingrédients' : 'Scan Ingredients',
  );
  String get homeAddManually => _t(
    'homeAddManually',
    () => isFrench ? 'Ajouter Manuellement' : 'Add Manually',
  );
  String get homeRecentScans =>
      _t('homeRecentScans', () => isFrench ? 'Scans Récents' : 'Recent Scans');
  String get homeViewAll =>
      _t('homeViewAll', () => isFrench ? 'Voir Tout' : 'View All');
  String get homeTryDemo =>
      _t('homeTryDemo', () => isFrench ? 'Essayer la démo' : 'Try Demo');
  String get homeDemoSubtitle => _t(
    'homeDemoSubtitle',
    () => isFrench ? 'Voir Dosely en action' : 'See Dosely in action',
  );

  // --- SETTINGS APPEARANCE ---
  String get settingsAppearance =>
      _t('settingsAppearance', () => isFrench ? 'Apparence' : 'Appearance');
  String get settingsHighContrast => _t(
    'settingsHighContrast',
    () => isFrench ? 'Contraste Élevé' : 'High Contrast',
  );
  String get settingsColorblind => _t(
    'settingsColorblind',
    () => isFrench ? 'Mode Daltonien' : 'Colorblind Mode',
  );
  String get settingsColorblindNone => _t(
    'settingsColorblindNone',
    () => isFrench ? 'Vision Normale' : 'Normal Vision',
  );
  String get settingsColorblindProtanopia => _t(
    'settingsColorblindProtanopia',
    () => isFrench ? 'Protanopie (Rouge)' : 'Protanopia (Red-Blind)',
  );
  String get settingsColorblindDeuteranopia => _t(
    'settingsColorblindDeuteranopia',
    () => isFrench ? 'Deutéranopie (Vert)' : 'Deuteranopia (Green-Blind)',
  );
  String get settingsColorblindTritanopia => _t(
    'settingsColorblindTritanopia',
    () => isFrench ? 'Tritanopie (Bleu)' : 'Tritanopia (Blue-Blind)',
  );
  String get settingsSpeed =>
      _t('settingsSpeed', () => isFrench ? 'Vitesse' : 'Speed');
  String get settingsTtsComingSoon => _t(
    'settingsTtsComingSoon',
    () => isFrench ? 'Test TTS bientôt disponible !' : 'TTS test coming soon!',
  );
  String get settingsHistoryCleared => _t(
    'settingsHistoryCleared',
    () => isFrench ? 'Historique effacé !' : 'History cleared!',
  );
  String get settingsAddLanguage => _t(
    'settingsAddLanguage',
    () => isFrench ? 'Ajouter une langue' : 'Add Language',
  );
  String get settingsEnterLanguage => _t(
    'settingsEnterLanguage',
    () =>
        isFrench
            ? 'Entrez la langue souhaitée.'
            : 'Enter the language you want.',
  );
  String get settingsTranslate =>
      _t('settingsTranslate', () => isFrench ? 'Traduire' : 'Translate');
  String get settingsSimplifying => _t(
    'settingsSimplifying',
    () => isFrench ? 'Simplification...' : 'Simplifying...',
  );
  String get settingsSimplified => _t(
    'settingsSimplified',
    () => isFrench ? 'Médicaments simplifiés !' : 'Medications simplified!',
  );

  // --- ONBOARDING DETAILS ---
  String get genderFemale =>
      _t('genderFemale', () => isFrench ? 'Femme' : 'Female');
  String get genderMale => _t('genderMale', () => isFrench ? 'Homme' : 'Male');
  String get genderOther =>
      _t('genderOther', () => isFrench ? 'Autre' : 'Other');
  String get onboardingMicHint => _t(
    'onboardingMicHint',
    () =>
        isFrench
            ? 'Appuyez pour enregistrer vocalement.'
            : 'Tap the mic to record your notes by voice.',
  );

  // --- SCHEDULE & MEDS STATUS ---
  String get scheduleNextIn => _t(
    'scheduleNextIn',
    () =>
        isFrench
            ? 'Prochain médicament dans ~{time}'
            : 'Next medication in ~{time}',
  );
  String scheduleNextInDetail(String time) =>
      scheduleNextIn.replaceAll('{time}', time);

  String get scheduleNoUpcoming => _t(
    'scheduleNoUpcoming',
    () => isFrench ? 'Aucun médicament à venir' : 'No upcoming medications',
  );
  String get scheduleEmpty => _t(
    'scheduleEmpty',
    () => isFrench ? 'Votre programme est vide' : 'Your schedule is empty',
  );
  String get scheduleRemoved => _t(
    'scheduleRemoved',
    () =>
        isFrench ? '{med} retiré du programme' : '{med} removed from schedule',
  );
  String scheduleRemovedItem(String med) =>
      scheduleRemoved.replaceAll('{med}', med);

  // --- MEDICATION ACTIONS ---
  String get actionDelete =>
      _t('actionDelete', () => isFrench ? 'Supprimer' : 'Delete');
  String get actionSchedule =>
      _t('actionSchedule', () => isFrench ? 'Planifier' : 'Schedule');
  String get actionUndo =>
      _t('actionUndo', () => isFrench ? 'Annuler' : 'Undo');
  String get medsNoneYet => _t(
    'medsNoneYet',
    () => isFrench ? 'Aucun médicament' : 'No medications yet',
  );
  String get medsDeleteTitle => _t(
    'medsDeleteTitle',
    () => isFrench ? 'Supprimer le médicament ?' : 'Delete Medication?',
  );
  String get medsDeleteContent => _t(
    'medsDeleteContent',
    () =>
        isFrench
            ? 'Voulez-vous vraiment supprimer {med} ?'
            : 'Are you sure you want to remove {med}?',
  );
  String medsDeleteConfirm(String med) =>
      medsDeleteContent.replaceAll('{med}', med);

  String get medsAddedSchedule => _t(
    'medsAddedSchedule',
    () => isFrench ? '{med} ajouté au programme' : '{med} added to schedule',
  );
  String medsAddedScheduleItem(String med) =>
      medsAddedSchedule.replaceAll('{med}', med);

  String get medsRemoved =>
      _t('medsRemoved', () => isFrench ? '{med} supprimé' : '{med} removed');
  String medsRemovedItem(String med) => medsRemoved.replaceAll('{med}', med);

  // --- STATUS BADGES ---
  String get statusSafeBadge =>
      _t('statusSafeBadge', () => isFrench ? 'SÛR' : 'SAFE');
  String get statusCautionBadge =>
      _t('statusCautionBadge', () => isFrench ? 'ATTENTION' : 'CAUTION');
  String get statusConflictBadge =>
      _t('statusConflictBadge', () => isFrench ? 'CONFLIT' : 'CONFLICT');

  String get homeSearchWithAI => _t(
    'homeSearchWithAI',
    () => isFrench ? 'Rechercher avec l\'IA' : 'Search with AI',
  );
  String get homeMedicationAdded => _t(
    'homeMedicationAdded',
    () => isFrench ? 'Médicament ajouté' : 'Medication added',
  );
  String get homeNoRecentScans => _t(
    'homeNoRecentScans',
    () => isFrench ? 'Aucun scan récent' : 'No recent scans',
  );

  String get readAloud =>
      _t('readAloud', () => isFrench ? 'Lire à haute voix' : 'Read Aloud');

  // --- STATUS ---
  String get statusSafe => _t('statusSafe', () => isFrench ? 'Sûr' : 'Safe');
  String get statusCaution =>
      _t('statusCaution', () => isFrench ? 'Attention' : 'Caution');
  String get statusConflict =>
      _t('statusConflict', () => isFrench ? 'Conflit' : 'Conflict');

  // --- SCAN & DETAILS ---
  String get scanAnalyzing => _t(
    'scanAnalyzing',
    () => isFrench ? 'Analyse du médicament...' : 'Analyzing Medicine...',
  );
  String get scanAnalyzingWait => _t(
    'scanAnalyzingWait',
    () =>
        isFrench
            ? 'Cela peut prendre quelques secondes'
            : 'This may take a few seconds',
  );
  String get scanError =>
      _t('scanError', () => isFrench ? 'Erreur d\'analyse' : 'Error analyzing');
  String get scanResultTitle => _t(
    'scanResultTitle',
    () => isFrench ? 'Résultat du Scan' : 'Scan Result',
  );
  String get scanEstimated =>
      _t('scanEstimated', () => isFrench ? '(Estimé)' : '(Estimated)');
  String get scanRisksConflicts => _t(
    'scanRisksConflicts',
    () => isFrench ? 'Risques et Conflits' : 'Risks & Conflicts',
  );
  String get scanDetails =>
      _t('scanDetails', () => isFrench ? 'Détails' : 'Details');
  String get scanAbout => _t(
    'scanAbout',
    () => isFrench ? 'À propos de ce médicament' : 'About this medication',
  );
  String get scanAddedToMeds => _t(
    'scanAddedToMeds',
    () => isFrench ? 'Ajouté à mes médicaments' : 'Added to My Meds',
  );
  String get scanAddToMeds => _t(
    'scanAddToMeds',
    () => isFrench ? 'Ajouter à mes médicaments' : 'Add to My Meds',
  );

  // --- DIALOGS ---
  String get dialogPrescriptionDetails => _t(
    'dialogPrescriptionDetails',
    () => isFrench ? 'Détails de la prescription' : 'Prescription Details',
  );
  String get dialogPrescriptionQuestion => _t(
    'dialogPrescriptionQuestion',
    () =>
        isFrench
            ? 'Comment cela vous a-t-il été prescrit ?'
            : 'How were you prescribed to take this?',
  );
  String get dialogSearchMedication => _t(
    'dialogSearchMedication',
    () => isFrench ? 'Rechercher un médicament' : 'Search Medication',
  );
  String get dialogSearchHint => _t(
    'dialogSearchHint',
    () =>
        isFrench
            ? 'Décrivez le médicament ou entrez son nom'
            : 'Describe the medication or enter its name.',
  );
  String get dialogCancel =>
      _t('dialogCancel', () => isFrench ? 'Annuler' : 'Cancel');
  String get dialogSearch =>
      _t('dialogSearch', () => isFrench ? 'Rechercher' : 'Search');
  String get dialogContinue =>
      _t('dialogContinue', () => isFrench ? 'Continuer' : 'Continue');
  String get dialogFrequency =>
      _t('dialogFrequency', () => isFrench ? 'Fréquence' : 'Frequency');
  String get dialogInstructions => _t(
    'dialogInstructions',
    () => isFrench ? 'Instructions' : 'Instructions',
  );
  String get dialogAutoDetectHint => _t(
    'dialogAutoDetectHint',
    () =>
        isFrench
            ? 'Laisser vide pour détecter automatiquement. (Caution: Vérifier l\'estimation)'
            : 'Leave blank to auto-detect from label. The AI will give its best guess on when you should take it based on your profile (Caution: Verify estimation).',
  );

  // --- PROFILE ---
  String get profileTitle =>
      _t('profileTitle', () => isFrench ? 'Mon Profil' : 'My Profile');
  String get profileAge => _t('profileAge', () => isFrench ? 'Âge' : 'Age');
  String get profileSex => _t('profileSex', () => isFrench ? 'Sexe' : 'Sex');
  String get profilePregnancy =>
      _t('profilePregnancy', () => isFrench ? 'Grossesse' : 'Pregnancy Status');
  String get profileNotPregnant => _t(
    'profileNotPregnant',
    () => isFrench ? 'Pas Enceinte' : 'Not Pregnant',
  );
  String get profileMedicalProfile => _t(
    'profileMedicalProfile',
    () => isFrench ? 'Profil Médical' : 'Medical Profile',
  );
  String get profileAllergies =>
      _t('profileAllergies', () => isFrench ? 'Allergies' : 'Allergies');
  String get profileConditions =>
      _t('profileConditions', () => isFrench ? 'Conditions' : 'Conditions');
  String get profileEditFull => _t(
    'profileEditFull',
    () => isFrench ? 'Modifier le profil complet' : 'Edit Full Profile',
  );
  String get profileEdit =>
      _t('profileEdit', () => isFrench ? 'Modifier' : 'Edit');
  String get profileNoAllergies => _t(
    'profileNoAllergies',
    () => isFrench ? 'Aucune allergie répertoriée' : 'No allergies listed',
  );
  String get profileNoConditions => _t(
    'profileNoConditions',
    () => isFrench ? 'Aucune condition répertoriée' : 'No conditions listed',
  );

  // --- SETTINGS ---
  String get settingsTitle =>
      _t('settingsTitle', () => isFrench ? 'Paramètres' : 'Settings');
  String get settingsLanguage =>
      _t('settingsLanguage', () => isFrench ? 'Langue' : 'Language');
  String get settingsTextSize =>
      _t('settingsTextSize', () => isFrench ? 'Taille du texte' : 'Text Size');
  String get settingsTextNormal =>
      _t('settingsTextNormal', () => isFrench ? 'Normal' : 'Normal');
  String get settingsTextLarge =>
      _t('settingsTextLarge', () => isFrench ? 'Grand' : 'Large');
  String get settingsTextExtraLarge => _t(
    'settingsTextExtraLarge',
    () => isFrench ? 'Très Grand' : 'Extra Large',
  );
  String get settingsVoice => _t(
    'settingsVoice',
    () => isFrench ? 'Paramètres Vocaux' : 'Voice Settings',
  );
  String get settingsVoiceSlow =>
      _t('settingsVoiceSlow', () => isFrench ? 'Lent' : 'Slow');
  String get settingsVoiceNormal =>
      _t('settingsVoiceNormal', () => isFrench ? 'Normal' : 'Normal');
  String get settingsVoiceFast =>
      _t('settingsVoiceFast', () => isFrench ? 'Rapide' : 'Fast');
  String get settingsTestVoice =>
      _t('settingsTestVoice', () => isFrench ? 'Tester la voix' : 'Test Voice');
  String get settingsSimpleMode => _t(
    'settingsSimpleMode',
    () => isFrench ? 'Mode Langage Simple' : 'Simple Language Mode',
  );
  String get settingsSimpleModeSubtitle => _t(
    'settingsSimpleModeSubtitle',
    () =>
        isFrench ? 'Expliquez comme si j\'avais 12 ans' : "Explain like I'm 12",
  );
  String get settingsClearHistory => _t(
    'settingsClearHistory',
    () => isFrench ? 'Effacer l\'historique' : 'Clear Scan History',
  );
  String get settingsAbout => _t(
    'settingsAbout',
    () => isFrench ? 'À propos de Dosely' : 'About Dosely',
  );
  String get settingsDisclaimer => _t(
    'settingsDisclaimer',
    () =>
        isFrench
            ? 'Avertissement et sources de données'
            : 'Disclaimer & Data Sources',
  );
  String get settingsPrivacy => _t(
    'settingsPrivacy',
    () => isFrench ? 'Politique de confidentialité' : 'Privacy Policy',
  );

  // --- MEDICATIONS ---
  String get medsTitle =>
      _t('medsTitle', () => isFrench ? 'Mes Médicaments' : 'My Medications');
  String get medsActive => _t(
    'medsActive',
    () => isFrench ? 'Médicaments Actifs' : 'Active Medications',
  );
  String get medsExport => _t(
    'medsExport',
    () => isFrench ? 'Exporter le résumé (PDF)' : 'Export Summary (PDF)',
  );
  String get medsShare => _t(
    'medsShare',
    () => isFrench ? 'Partager avec un soignant' : 'Share with Caregiver',
  );
  String get medsLastScan =>
      _t('medsLastScan', () => isFrench ? 'Dernier scan' : 'Last scan');
  String get medsToday =>
      _t('medsToday', () => isFrench ? 'Aujourd\'hui' : 'Today');
  String get medsYesterday =>
      _t('medsYesterday', () => isFrench ? 'Hier' : 'Yesterday');

  // Formatted String for Days Ago
  String get medsDaysAgoFormat => _t(
    'medsDaysAgoFormat',
    () => isFrench ? 'Il y a {days} jours' : '{days} days ago',
  );
  String medsDaysAgo(int days) =>
      medsDaysAgoFormat.replaceAll('{days}', days.toString());

  // --- SCHEDULE ---
  String get scheduleTitle => _t(
    'scheduleTitle',
    () => isFrench ? 'Votre plan pour aujourd\'hui' : 'Your Plan for Today',
  );
  String get scheduleReview => _t(
    'scheduleReview',
    () =>
        isFrench
            ? 'Vérifiez votre médicament scanné'
            : 'Review your scanned medication',
  );
  String get scheduleReadPlan => _t(
    'scheduleReadPlan',
    () => isFrench ? 'Lire le plan à haute voix' : 'Read Plan Aloud',
  );
  String get scheduleDaily => _t(
    'scheduleDaily',
    () => isFrench ? 'Programme quotidien' : 'Daily Schedule',
  );
  String get scheduleMorning =>
      _t('scheduleMorning', () => isFrench ? 'Matin' : 'Morning');
  String get scheduleMidday =>
      _t('scheduleMidday', () => isFrench ? 'Midi' : 'Midday');
  String get scheduleEvening =>
      _t('scheduleEvening', () => isFrench ? 'Soir' : 'Evening');
  String get scheduleNight =>
      _t('scheduleNight', () => isFrench ? 'Nuit' : 'Night');
  String get scheduleNoMeds => _t(
    'scheduleNoMeds',
    () => isFrench ? 'Aucun médicament prévu' : 'No medications scheduled',
  );
  String get scheduleTablet =>
      _t('scheduleTablet', () => isFrench ? 'comprimé' : 'tablet');
  String get scheduleWithFood => _t(
    'scheduleWithFood',
    () => isFrench ? 'Avec de la nourriture' : 'With food',
  );
  String get scheduleAddAnother => _t(
    'scheduleAddAnother',
    () => isFrench ? 'Ajouter un autre médicament' : 'Add Another Medication',
  );
  String get scheduleHighConfidence => _t(
    'scheduleHighConfidence',
    () => isFrench ? 'Confiance Élevée' : 'High Confidence',
  );
  String get scheduleMediumConfidence => _t(
    'scheduleMediumConfidence',
    () => isFrench ? 'Confiance Moyenne' : 'Medium Confidence',
  );
  String get scheduleLowConfidence => _t(
    'scheduleLowConfidence',
    () => isFrench ? 'Faible Confiance' : 'Low Confidence',
  );

  // --- CONFLICTS ---
  String get conflictTitle => _t(
    'conflictTitle',
    () =>
        isFrench
            ? 'Ingrédient dupliqué possible'
            : 'Possible duplicate ingredient',
  );

  String get conflictDescriptionFormat => _t(
    'conflictDescriptionFormat',
    () =>
        isFrench
            ? 'Vous prenez déjà {ingredient} dans un autre médicament. Cela peut dépasser les limites quotidiennes de sécurité.'
            : 'You are already taking {ingredient} in another medication. This may exceed safe daily limits.',
  );
  String conflictDescription(String ingredient) =>
      conflictDescriptionFormat.replaceAll('{ingredient}', ingredient);

  String get conflictViewDetails => _t(
    'conflictViewDetails',
    () => isFrench ? 'Voir les détails' : 'View Details',
  );

  // --- SIDE EFFECTS ---
  String get sideEffectsTitle => _t(
    'sideEffectsTitle',
    () => isFrench ? 'Effets Secondaires' : 'Side Effects',
  );
  String get sideEffectsCommon => _t(
    'sideEffectsCommon',
    () => isFrench ? 'Effets Secondaires Courants' : 'Common Side Effects',
  );
  String get sideEffectsSerious =>
      _t('sideEffectsSerious', () => isFrench ? 'Grave' : 'Serious');
  String get sideEffectsHelp =>
      _t('sideEffectsHelp', () => isFrench ? 'Obtenir de l\'aide' : 'Get Help');
  String get sideEffectsVeryCommon => _t(
    'sideEffectsVeryCommon',
    () => isFrench ? 'Très Courant' : 'Very Common',
  );
  String get sideEffectsOccasional => _t(
    'sideEffectsOccasional',
    () => isFrench ? 'Occasionnel' : 'Occasional',
  );
  String get sideEffectsCallPharmacist => _t(
    'sideEffectsCallPharmacist',
    () => isFrench ? 'Appeler le pharmacien' : 'Call Pharmacist',
  );
  String get sideEffectsEmergency => _t(
    'sideEffectsEmergency',
    () => isFrench ? 'Conseils d\'urgence' : 'Emergency Guidance',
  );

  // --- DISCLAIMER ---
  String get disclaimerTitle =>
      _t('disclaimerTitle', () => isFrench ? 'Important' : 'Important');
  String get disclaimerText => _t(
    'disclaimerText',
    () =>
        isFrench
            ? 'Dosely est un assistant d\'information. Nous ne fournissons PAS de conseils médicaux. Consultez toujours votre médecin ou votre pharmacien avant de prendre des décisions concernant les médicaments.'
            : 'Dosely is an information assistant. We are NOT providing medical advice. Always consult your doctor or pharmacist before making medication decisions.',
  );
  String get disclaimerAgree =>
      _t('disclaimerAgree', () => isFrench ? 'Je Comprends' : 'I Understand');

  // --- ONBOARDING ---
  String get onboardingWelcome => _t(
    'onboardingWelcome',
    () => isFrench ? 'Bienvenue sur Dosely' : 'Welcome to Dosely',
  );
  String get onboardingChooseLanguage => _t(
    'onboardingChooseLanguage',
    () => isFrench ? 'Choisissez votre langue' : 'Choose your language',
  );
  String get onboardingChooseTextSize => _t(
    'onboardingChooseTextSize',
    () => isFrench ? 'Choisissez la taille du texte' : 'Choose text size',
  );
  String get onboardingContinue =>
      _t('onboardingContinue', () => isFrench ? 'Continuer' : 'Continue');
  String get onboardingSkip =>
      _t('onboardingSkip', () => isFrench ? 'Sauter' : 'Skip');
  String get onboardingGetStarted =>
      _t('onboardingGetStarted', () => isFrench ? 'Commencer' : 'Get Started');

  String get onboardingTellUs => _t(
    'onboardingTellUs',
    () => isFrench ? 'Parlez-nous de vous' : 'Tell us about you',
  );
  String get onboardingNameLabel =>
      _t('onboardingNameLabel', () => isFrench ? 'Nom' : 'Name');
  String get onboardingNameHint => _t(
    'onboardingNameHint',
    () =>
        isFrench
            ? 'Comment devons-nous vous appeler ?'
            : 'What should we call you?',
  );
  String get onboardingAgeLabel =>
      _t('onboardingAgeLabel', () => isFrench ? 'Âge' : 'Age');
  String get onboardingPronounsLabel =>
      _t('onboardingPronounsLabel', () => isFrench ? 'Pronoms' : 'Pronouns');
  String get onboardingPronounsHint => _t(
    'onboardingPronounsHint',
    () => isFrench ? 'ex. Elle/La' : 'e.g. She/Her',
  );
  String get onboardingSexLabel =>
      _t('onboardingSexLabel', () => isFrench ? 'Sexe' : 'Sex');
  String get onboardingPregnantLabel => _t(
    'onboardingPregnantLabel',
    () => isFrench ? 'Êtes-vous enceinte ?' : 'Are you pregnant?',
  );

  String get onboardingMedicalTitle => _t(
    'onboardingMedicalTitle',
    () => isFrench ? 'Profil Médical' : 'Medical Profile',
  );
  String get onboardingMedicalDesc => _t(
    'onboardingMedicalDesc',
    () =>
        isFrench
            ? 'Veuillez énumérer vos allergies et conditions médicales connues. Nous analyserons cela pour personnaliser vos alertes de sécurité.'
            : 'Please list any known allergies and medical conditions. We will analyze this to personalize your safety alerts.',
  );
  String get onboardingMedicalHint => _t(
    'onboardingMedicalHint',
    () =>
        isFrench
            ? 'ex. Allergie aux arachides, Asthme, Diabète de type 2...'
            : 'e.g., Peanut allergy, Asthma, Diabetes type 2...',
  );
  String get onboardingAiAnalysis => _t(
    'onboardingAiAnalysis',
    () =>
        isFrench
            ? 'L\'IA analysera vos notes pour identifier automatiquement les allergies et les conditions.'
            : 'AI will analyze your notes to identify allergies and conditions automatically.',
  );

  String get onboardingColorTitle => _t(
    'onboardingColorTitle',
    () => isFrench ? 'Accessibilité des Couleurs' : 'Color Accessibility',
  );
  String get onboardingColorSubtitle => _t(
    'onboardingColorSubtitle',
    () =>
        isFrench
            ? 'Ajustez les couleurs pour une meilleure visibilité.'
            : 'Adjust colors for better visibility.',
  );
  String get onboardingColorPrimary =>
      _t('onboardingColorPrimary', () => isFrench ? 'Primaire' : 'Primary');
  String get onboardingColorError =>
      _t('onboardingColorError', () => isFrench ? 'Erreur' : 'Error');
  String get onboardingColorSuccess =>
      _t('onboardingColorSuccess', () => isFrench ? 'Succès' : 'Success');

  // --- SERIALIZATION FOR AI ---
  Map<String, String> toMap() {
    return {
      'appName': appName,
      'back': back,
      'speed': speed,
      'tagline': tagline,
      'navHome': navHome,
      'navMyMeds': navMyMeds,
      'navProfile': navProfile,
      'navSettings': navSettings,
      'navSchedule': navSchedule,
      'homeTitle': homeTitle,
      'homeScanLabel': homeScanLabel,
      'homeScanSubtitle': homeScanSubtitle,
      'homeScanIngredients': homeScanIngredients,
      'homeAddManually': homeAddManually,
      'homeRecentScans': homeRecentScans,
      'homeViewAll': homeViewAll,
      'homeTryDemo': homeTryDemo,
      'homeDemoSubtitle': homeDemoSubtitle,
      'readAloud': readAloud,
      'statusSafe': statusSafe,
      'statusCaution': statusCaution,
      'statusConflict': statusConflict,
      'profileTitle': profileTitle,
      'profileAge': profileAge,
      'profileSex': profileSex,
      'profilePregnancy': profilePregnancy,
      'profileNotPregnant': profileNotPregnant,
      'profileMedicalProfile': profileMedicalProfile,
      'profileAllergies': profileAllergies,
      'profileConditions': profileConditions,
      'profileEditFull': profileEditFull,
      'profileEdit': profileEdit,
      'settingsTitle': settingsTitle,
      'settingsLanguage': settingsLanguage,
      'settingsTextSize': settingsTextSize,
      'settingsTextNormal': settingsTextNormal,
      'settingsTextLarge': settingsTextLarge,
      'settingsTextExtraLarge': settingsTextExtraLarge,
      'settingsVoice': settingsVoice,
      'settingsVoiceSlow': settingsVoiceSlow,
      'settingsVoiceNormal': settingsVoiceNormal,
      'settingsVoiceFast': settingsVoiceFast,
      'settingsTestVoice': settingsTestVoice,
      'settingsSimpleMode': settingsSimpleMode,
      'settingsSimpleModeSubtitle': settingsSimpleModeSubtitle,
      'settingsClearHistory': settingsClearHistory,
      'settingsAbout': settingsAbout,
      'settingsDisclaimer': settingsDisclaimer,
      'settingsPrivacy': settingsPrivacy,
      'medsTitle': medsTitle,
      'medsActive': medsActive,
      'medsExport': medsExport,
      'medsShare': medsShare,
      'medsLastScan': medsLastScan,
      'medsToday': medsToday,
      'medsYesterday': medsYesterday,
      'medsDaysAgoFormat': medsDaysAgoFormat,
      'scheduleTitle': scheduleTitle,
      'scheduleReview': scheduleReview,
      'scheduleReadPlan': scheduleReadPlan,
      'scheduleDaily': scheduleDaily,
      'scheduleMorning': scheduleMorning,
      'scheduleMidday': scheduleMidday,
      'scheduleEvening': scheduleEvening,
      'scheduleNight': scheduleNight,
      'scheduleNoMeds': scheduleNoMeds,
      'scheduleTablet': scheduleTablet,
      'scheduleWithFood': scheduleWithFood,
      'scheduleAddAnother': scheduleAddAnother,
      'scheduleHighConfidence': scheduleHighConfidence,
      'scheduleMediumConfidence': scheduleMediumConfidence,
      'scheduleLowConfidence': scheduleLowConfidence,
      'conflictTitle': conflictTitle,
      'conflictDescriptionFormat': conflictDescriptionFormat,
      'conflictViewDetails': conflictViewDetails,
      'sideEffectsTitle': sideEffectsTitle,
      'sideEffectsCommon': sideEffectsCommon,
      'sideEffectsSerious': sideEffectsSerious,
      'sideEffectsHelp': sideEffectsHelp,
      'sideEffectsVeryCommon': sideEffectsVeryCommon,
      'sideEffectsOccasional': sideEffectsOccasional,
      'sideEffectsCallPharmacist': sideEffectsCallPharmacist,
      'sideEffectsEmergency': sideEffectsEmergency,
      'disclaimerTitle': disclaimerTitle,
      'disclaimerText': disclaimerText,
      'disclaimerAgree': disclaimerAgree,
      'onboardingWelcome': onboardingWelcome,
      'onboardingChooseLanguage': onboardingChooseLanguage,
      'onboardingChooseTextSize': onboardingChooseTextSize,
      'onboardingContinue': onboardingContinue,
      'onboardingSkip': onboardingSkip,
      'onboardingGetStarted': onboardingGetStarted,
      'onboardingTellUs': onboardingTellUs,
      'onboardingNameLabel': onboardingNameLabel,
      'onboardingNameHint': onboardingNameHint,
      'onboardingAgeLabel': onboardingAgeLabel,
      'onboardingPronounsLabel': onboardingPronounsLabel,
      'onboardingPronounsHint': onboardingPronounsHint,
      'onboardingSexLabel': onboardingSexLabel,
      'onboardingPregnantLabel': onboardingPregnantLabel,
      'onboardingMedicalTitle': onboardingMedicalTitle,
      'onboardingMedicalDesc': onboardingMedicalDesc,
      'onboardingMedicalHint': onboardingMedicalHint,
      'onboardingAiAnalysis': onboardingAiAnalysis,
      'onboardingColorTitle': onboardingColorTitle,
      'onboardingColorSubtitle': onboardingColorSubtitle,
      'onboardingColorPrimary': onboardingColorPrimary,
      'onboardingColorError': onboardingColorError,
      'onboardingColorSuccess': onboardingColorSuccess,
      'homeSearchWithAI': homeSearchWithAI,
      'settingsAppearance': settingsAppearance,
      'settingsHighContrast': settingsHighContrast,
      'settingsColorblind': settingsColorblind,
      'settingsColorblindNone': settingsColorblindNone,
      'settingsColorblindProtanopia': settingsColorblindProtanopia,
      'settingsColorblindDeuteranopia': settingsColorblindDeuteranopia,
      'settingsColorblindTritanopia': settingsColorblindTritanopia,
      'settingsSpeed': settingsSpeed,
      'settingsTtsComingSoon': settingsTtsComingSoon,
      'settingsHistoryCleared': settingsHistoryCleared,
      'settingsAddLanguage': settingsAddLanguage,
      'settingsEnterLanguage': settingsEnterLanguage,
      'settingsTranslate': settingsTranslate,
      'settingsSimplifying': settingsSimplifying,
      'settingsSimplified': settingsSimplified,
      'genderFemale': genderFemale,
      'genderMale': genderMale,
      'genderOther': genderOther,
      'onboardingMicHint': onboardingMicHint,
      'scheduleNextIn': scheduleNextIn,
      'scheduleNoUpcoming': scheduleNoUpcoming,
      'scheduleEmpty': scheduleEmpty,
      'scheduleRemoved': scheduleRemoved,
      'actionDelete': actionDelete,
      'actionSchedule': actionSchedule,
      'actionUndo': actionUndo,
      'medsNoneYet': medsNoneYet,
      'medsDeleteTitle': medsDeleteTitle,
      'medsDeleteContent': medsDeleteContent,
      'medsAddedSchedule': medsAddedSchedule,
      'medsRemoved': medsRemoved,
      'statusSafeBadge': statusSafeBadge,
      'statusCautionBadge': statusCautionBadge,
      'statusConflictBadge': statusConflictBadge,
      'homeMedicationAdded': homeMedicationAdded,
      'homeNoRecentScans': homeNoRecentScans,
      'profileNoAllergies': profileNoAllergies,
      'profileNoConditions': profileNoConditions,
      'scanAnalyzing': scanAnalyzing,
      'scanAnalyzingWait': scanAnalyzingWait,
      'scanError': scanError,
      'scanResultTitle': scanResultTitle,
      'scanEstimated': scanEstimated,
      'scanRisksConflicts': scanRisksConflicts,
      'scanDetails': scanDetails,
      'scanAbout': scanAbout,
      'scanAddedToMeds': scanAddedToMeds,
      'scanAddToMeds': scanAddToMeds,
      'dialogPrescriptionDetails': dialogPrescriptionDetails,
      'dialogPrescriptionQuestion': dialogPrescriptionQuestion,
      'dialogSearchMedication': dialogSearchMedication,
      'dialogSearchHint': dialogSearchHint,
      'dialogCancel': dialogCancel,
      'dialogSearch': dialogSearch,
      'dialogContinue': dialogContinue,
      'dialogFrequency': dialogFrequency,
      'dialogInstructions': dialogInstructions,
      'dialogAutoDetectHint': dialogAutoDetectHint,
    };
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(
      AppLocalizations(locale, AppLocalizationsDynamic.currentDynamicMap),
    );
  }

  @override
  bool isSupported(Locale locale) => true; // Support all locales now

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => true; // Always reload allows dynamic updates
}

// Add static field to AppLocalizations for the active map
extension AppLocalizationsDynamic on AppLocalizations {
  static Map<String, String>? currentDynamicMap;
}
