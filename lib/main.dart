import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'core/localization/app_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/providers/settings_provider.dart';
import 'presentation/screens/main_shell.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'core/services/storage_service.dart';
import 'core/providers/medication_provider.dart';
import 'core/providers/profile_provider.dart';
import 'core/providers/schedule_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider(prefs)),
        ChangeNotifierProvider(
          create: (_) => MedicationProvider(storageService)..loadMedications(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(storageService)..loadProfile(),
        ),
        ChangeNotifierProvider(
          create: (_) => ScheduleProvider(storageService)..loadSchedule(),
        ),
      ],
      child: const DoselyApp(),
    ),
  );
}

class DoselyApp extends StatelessWidget {
  const DoselyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return MaterialApp(
      title: 'Dosely',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(
        settings.textScaleFactor,
        colorblindMode: settings.colorblindMode,
      ),
      themeAnimationDuration: Duration.zero,
      themeAnimationCurve: Curves.linear,

      // Localization
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: settings.locale,

      home:
          settings.hasCompletedOnboarding
              ? const MainShell()
              : const OnboardingScreen(),
    );
  }
}
