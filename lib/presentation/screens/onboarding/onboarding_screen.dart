import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/models/profile.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/ai_service.dart';
import 'package:flutter/services.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http; // Add http import for web blob reading
import 'dart:async';
import 'dart:typed_data'; // Add typed_data for Uint8List

// Conditional import for File class (only available on non-web platforms)
import 'dart:io' if (dart.library.html) '../../../core/utils/web_stub.dart';

/// Onboarding screen - quick setup before main app
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 6;
  bool _isAnalyzing = false; // Loading state for AI

  // Page 1: Language (Managed by SettingsProvider)

  // Page 4: Profile Basics
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _pronounsController = TextEditingController();
  String _sex = '';
  bool _isPregnant = false;

  // Page 5: Medical Notes
  final TextEditingController _medicalNotesController = TextEditingController();
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _isTranscribing = false;
  DateTime? _recordingStartTime;
  Timer? _amplitudeTimer;
  double _currentAmplitude = -160.0; // Min dB
  int _animationTick = 0; // For animated visualizer

  final _aiService = AIService();

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _pronounsController.dispose();
    _medicalNotesController.dispose();
    _audioRecorder.dispose();
    _amplitudeTimer?.cancel();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        String? path;

        // On web, we don't use file paths - the record package uses blob URLs
        // On mobile/desktop, we use the documents directory
        if (!kIsWeb) {
          final directory = await getApplicationDocumentsDirectory();
          path = '${directory.path}/medical_notes_recording.wav';

          // Check if file exists and delete it to ensure fresh recording
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
          }
        }

        // Use opus encoder on web for better browser support, aacLc on mobile
        final config =
            kIsWeb
                ? const RecordConfig(encoder: AudioEncoder.wav)
                : const RecordConfig(encoder: AudioEncoder.wav);

        if (kIsWeb) {
          // On web, start without a path - uses blob storage
          await _audioRecorder.start(config, path: '');
        } else {
          await _audioRecorder.start(config, path: path!);
        }

        _recordingStartTime = DateTime.now();

        // Start polling amplitude and animation
        _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 100), (
          timer,
        ) async {
          try {
            final amp = await _audioRecorder.getAmplitude();
            if (mounted) {
              setState(() {
                _currentAmplitude = amp.current;
                _animationTick++;
              });
            }
          } catch (e) {
            // Just increment tick for animation even if amplitude fails
            if (mounted) {
              setState(() {
                _animationTick++;
              });
            }
          }
        });

        if (mounted) {
          setState(() => _isRecording = true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission required')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not start recording: $e')),
        );
      }
    }
  }

  /// Stops recording and returns the path to the recorded file.
  Future<String?> _stopRecordingInternal() async {
    _amplitudeTimer?.cancel();
    _amplitudeTimer = null;
    try {
      final path = await _audioRecorder.stop();
      setState(() => _isRecording = false);
      return path;
    } catch (e) {
      print('Error stopping recording: $e');
      setState(() => _isRecording = false);
      return null;
    }
  }

  Future<void> _handleStopAndTranscribe() async {
    // Check duration prevents accidental taps
    if (_recordingStartTime != null) {
      final duration = DateTime.now().difference(_recordingStartTime!);
      if (duration.inMilliseconds < 500) {
        await _stopRecordingInternal(); // Just stop logic
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Recording too short')));
        }
        return;
      }
    }

    final path = await _stopRecordingInternal();
    if (path != null) {
      if (mounted) setState(() => _isTranscribing = true);

      Uint8List? audioBytes;
      final languageCode = context.read<SettingsProvider>().locale.languageCode;

      try {
        if (kIsWeb) {
          // On web, path is a blob URL, download it using http
          final response = await http.get(Uri.parse(path));
          if (response.statusCode == 200) {
            audioBytes = response.bodyBytes;
          } else {
            debugPrint('Failed to download blob: ${response.statusCode}');
          }
        } else {
          // On mobile, read from file
          // We need to use the conditional import stub or just separate logic
          // Since we have the stub, we can use File if the path is valid?
          // Actually, best to just use dart:io File inside a !kIsWeb block if possible,
          // but since we can't import dart:io directly without conditional,
          // and we already have the conditional import as 'File' (via stub or io),
          // we can try to use it.
          final file = File(path);
          if (await file.exists()) {
            // We need readAsBytes, but our stub might not have it?
            // The real File has it. The stub needs to support it or we cast?
            // Simpler: Just rely on the fact that on mobile 'File' is 'dart:io.File'
            audioBytes = await file.readAsBytes();
          }
        }

        if (audioBytes != null) {
          final transcribedText = await _aiService.transcribeMedicalNotes(
            audioBytes,
            languageCode: languageCode,
          );

          if (mounted) {
            setState(() => _isTranscribing = false);
            if (transcribedText != null && transcribedText.isNotEmpty) {
              final currentText = _medicalNotesController.text;
              if (currentText.isEmpty) {
                _medicalNotesController.text = transcribedText;
              } else {
                _medicalNotesController.text = '$currentText $transcribedText';
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not transcribe audio')),
              );
            }
          }
        } else {
          if (mounted) {
            setState(() => _isTranscribing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not read audio file')),
            );
          }
        }
      } catch (e) {
        debugPrint('Error reading audio: $e');
        if (mounted) {
          setState(() => _isTranscribing = false);
        }
      }
    }
  }

  void _skipOnboarding() {
    // Create empty profile
    final emptyProfile = UserProfile.empty();
    context.read<ProfileProvider>().updateProfile(emptyProfile);

    // Save final settings
    final settings = context.read<SettingsProvider>();
    settings.completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    // If recording, stop and transribe first
    if (_isRecording) {
      await _handleStopAndTranscribe();
    }

    setState(() => _isAnalyzing = true);

    // Create profile from inputs
    final age = int.tryParse(_ageController.text) ?? 0;
    final notes = _medicalNotesController.text;

    List<String> allergies = [];
    List<String> conditions = [];

    // Use AI to parse notes if present
    if (notes.isNotEmpty) {
      try {
        final languageCode =
            context.read<SettingsProvider>().locale.languageCode;
        final parsedData = await _aiService.parseMedicalProfile(
          notes,
          languageCode: languageCode,
        );
        allergies = parsedData['allergies'] ?? [];
        conditions = parsedData['conditions'] ?? [];
      } catch (e) {
        print('Error parsing profile: $e');
      }
    }

    final profile = UserProfile(
      name: _nameController.text,
      pronouns: _pronounsController.text,
      age: age,
      sex: _sex,
      isPregnant: _isPregnant,
      allergies: allergies,
      conditions: conditions,
      medicalNotes: notes,
      memberSince: DateTime.now(),
    );

    if (mounted) {
      context.read<ProfileProvider>().updateProfile(profile);

      // Save settings
      final settings = context.read<SettingsProvider>();
      if (_nameController.text.isNotEmpty) {
        settings.setUserName(_nameController.text);
      }
      await settings.completeOnboarding();
    }

    // Safety check just in case
    if (mounted) {
      setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLastPage = _currentPage == _totalPages - 1;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Bar with Skip
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Progress Indicator
                      Row(
                        children: List.generate(
                          _totalPages,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  index <= _currentPage
                                      ? AppTheme.primary
                                      : AppTheme.border,
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _skipOnboarding,
                        child: Text(l10n.onboardingSkip),
                      ),
                    ],
                  ),
                ),

                // Pages
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable swipe to force validation/next button
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    children: [
                      _buildWelcomePage(context, l10n),
                      _buildTextSizePage(context, l10n),
                      _buildColorblindPage(context, l10n),
                      _buildDisclaimerPage(context, l10n),
                      _buildProfileBasicsPage(context, l10n),
                      _buildMedicalNotesPage(context, l10n),
                    ],
                  ),
                ),

                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      if (_currentPage > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Text(l10n.back),
                          ),
                        ),
                      if (_currentPage > 0) const SizedBox(width: 16),
                      Expanded(
                        flex: _currentPage == 0 ? 1 : 1,
                        child: ElevatedButton(
                          onPressed:
                              _isAnalyzing
                                  ? null
                                  : () {
                                    if (isLastPage) {
                                      _completeOnboarding();
                                    } else {
                                      _pageController.nextPage(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  },
                          child:
                              _isAnalyzing
                                  ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Text(
                                    isLastPage
                                        ? l10n.onboardingGetStarted
                                        : l10n.onboardingContinue,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Loading Overlay
            if (_isAnalyzing)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Analyzing Medical Profile...',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            // Language Loading Overlay
            if (context.watch<SettingsProvider>().isLanguageLoading)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Translating Application...',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                      Text(
                        'Converting content...',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Page 1: Welcome & Language
  Widget _buildWelcomePage(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Text(
                'D',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.onboardingWelcome,
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.tagline,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSub),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // Language Dropdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.onboardingChooseLanguage,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  border: Border.all(color: AppTheme.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value:
                        context.watch<SettingsProvider>().locale.languageCode,
                    isExpanded: true,
                    style: Theme.of(context).textTheme.bodyLarge,
                    dropdownColor: AppTheme.surface,
                    focusColor: Colors.transparent,
                    iconEnabledColor: AppTheme.primary,
                    items: [
                      const DropdownMenuItem(
                        value: 'en',
                        child: Text('English'),
                      ),
                      const DropdownMenuItem(
                        value: 'fr',
                        child: Text('Français'),
                      ),
                      if (context
                                  .watch<SettingsProvider>()
                                  .locale
                                  .languageCode ==
                              'x' &&
                          context
                                  .watch<SettingsProvider>()
                                  .customLanguageName !=
                              null)
                        DropdownMenuItem(
                          value: 'x',
                          child: Text(
                            context
                                .watch<SettingsProvider>()
                                .customLanguageName!,
                          ),
                        ),
                      const DropdownMenuItem(
                        value: 'add_custom',
                        child: Row(
                          children: [
                            Icon(Icons.add, size: 18),
                            SizedBox(width: 8),
                            Text('Add Language'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val == 'add_custom') {
                        _showAddLanguageDialog(
                          context,
                          context.read<SettingsProvider>(),
                        );
                      } else if (val != null) {
                        context.read<SettingsProvider>().setLocale(Locale(val));
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Page 2: Text Size (Reused implementation)
  Widget _buildTextSizePage(BuildContext context, AppLocalizations l10n) {
    // Watch settings instantly
    final settings = context.watch<SettingsProvider>();
    final currentTextSizeIndex = settings.textSizeIndex;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onboardingChooseTextSize,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the size that\'s comfortable for you',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSub),
          ),
          const SizedBox(height: 32),
          _buildTextSizeOption(
            context,
            l10n.settingsTextNormal,
            0,
            'Aa',
            18,
            currentTextSizeIndex,
          ),
          const SizedBox(height: 16),
          _buildTextSizeOption(
            context,
            l10n.settingsTextLarge,
            1,
            'Aa',
            24,
            currentTextSizeIndex,
          ),
          const SizedBox(height: 16),
          _buildTextSizeOption(
            context,
            l10n.settingsTextExtraLarge,
            2,
            'Aa',
            32,
            currentTextSizeIndex,
          ),
        ],
      ),
    );
  }

  Widget _buildTextSizeOption(
    BuildContext context,
    String label,
    int index,
    String preview,
    double previewSize,
    int currentIndex,
  ) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () {
        // Update immediately to affect entire app
        context.read<SettingsProvider>().setTextSize(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryLight : AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              preview,
              style: TextStyle(
                fontSize: previewSize,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.primary : AppTheme.textMain,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isSelected ? AppTheme.primary : AppTheme.textMain,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.primary, size: 24),
          ],
        ),
      ),
    );
  }

  // Page 2.5: Colorblind Mode
  Widget _buildColorblindPage(BuildContext context, AppLocalizations l10n) {
    final settings = context.watch<SettingsProvider>();
    final currentMode = settings.colorblindMode;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onboardingColorTitle,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingColorSubtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSub),
          ),
          const SizedBox(height: 24),

          // Preview Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            l10n.onboardingColorPrimary,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            l10n.onboardingColorError,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            l10n.onboardingColorSuccess,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildRadioOptionTile(context, 'Normal Vision', 0, currentMode),
          _buildRadioOptionTile(
            context,
            'Protanopia (Red-Blind)',
            1,
            currentMode,
          ),
          _buildRadioOptionTile(
            context,
            'Deuteranopia (Green-Blind)',
            2,
            currentMode,
          ),
          _buildRadioOptionTile(
            context,
            'Tritanopia (Blue-Blind)',
            3,
            currentMode,
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOptionTile(
    BuildContext context,
    String title,
    int value,
    int groupValue,
  ) {
    final isSelected = value == groupValue;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.read<SettingsProvider>().setColorblindMode(value);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  isSelected ? Theme.of(context).primaryColor : AppTheme.border,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color:
                isSelected
                    ? Theme.of(context).primaryColor.withOpacity(0.05)
                    : null,
          ),
          child: Row(
            children: [
              Radio<int>(
                value: value,
                groupValue: groupValue,
                onChanged: (val) {
                  if (val != null) {
                    context.read<SettingsProvider>().setColorblindMode(val);
                  }
                },
                activeColor: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Page 3: Disclaimer (Reused)
  Widget _buildDisclaimerPage(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, size: 64, color: AppTheme.primary),
          const SizedBox(height: 24),
          Text(
            l10n.disclaimerTitle,
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(
              l10n.disclaimerText,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Page 4: Profile Basics
  Widget _buildProfileBasicsPage(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onboardingTellUs,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),

          // Name
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.onboardingNameLabel,
              hintText: l10n.onboardingNameHint,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Age and Pronouns Row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: l10n.onboardingAgeLabel,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _pronounsController,
                  decoration: InputDecoration(
                    labelText: l10n.onboardingPronounsLabel,
                    hintText: l10n.onboardingPronounsHint,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Sex Radio Buttons
          Text(
            l10n.onboardingSexLabel,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              _buildRadioOption(l10n.genderFemale, 'Female'),
              _buildRadioOption(l10n.genderMale, 'Male'),
              _buildRadioOption(l10n.genderOther, 'Other'),
            ],
          ),

          const SizedBox(height: 16),
          // Pregnancy Switch
          SwitchListTile(
            title: Text(l10n.onboardingPregnantLabel),
            contentPadding: EdgeInsets.zero,
            value: _isPregnant,
            onChanged: (val) => setState(() => _isPregnant = val),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String label, String value) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: _sex,
      onChanged: (val) => setState(() => _sex = val!),
      contentPadding: EdgeInsets.zero,
      activeColor: AppTheme.primary,
    );
  }

  // Page 5: Medical Notes
  Widget _buildMedicalNotesPage(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onboardingMedicalTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingMedicalDesc,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSub),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _medicalNotesController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: l10n.onboardingMedicalHint,
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear, color: AppTheme.textSub),
                onPressed: () {
                  _medicalNotesController.clear();
                  setState(
                    () {},
                  ); // specific setState for clearing? check scoping
                },
              ),
            ),
            onChanged: (val) {
              // Rebuild to show/hide clear button if needed?
              // Or just keep it always visible or visible when not empty?
              // Creating a local SetState or just global setState is fine for this screen
              setState(() {});
            },
          ),
          const SizedBox(height: 16),
          // "Or" divider to indicate recording as an alternative
          Row(
            children: [
              Expanded(child: const Divider(color: AppTheme.border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'or',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSub,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              Expanded(child: const Divider(color: AppTheme.border)),
            ],
          ),
          const SizedBox(height: 16),
          // AI & Voice Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Voice Recorder Button
              GestureDetector(
                onLongPress: _startRecording, // Option for long press
                onLongPressUp: _handleStopAndTranscribe,
                onTap: () {
                  if (_isRecording) {
                    _handleStopAndTranscribe();
                  } else {
                    _startRecording();
                  }
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color:
                        _isRecording
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecording
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).primaryColor)
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child:
                      _isTranscribing
                          ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Icon(
                            _isRecording ? Icons.stop : Icons.mic,
                            color: Colors.white,
                          ),
                ),
              ),
              const SizedBox(width: 16),
              // Explanation Text & Visualizer
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isRecording
                          ? 'Recording... Tap to stop.'
                          : _isTranscribing
                          ? 'Transcribing audio...'
                          : l10n.onboardingAiAnalysis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            _isRecording
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).primaryColor,
                        fontStyle: FontStyle.italic,
                        fontWeight:
                            _isRecording || _isTranscribing
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                    ),
                    if (_isRecording)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: List.generate(5, (index) {
                            // Animated visualizer with sine wave effect
                            // Uses _animationTick for continuous animation
                            // and _currentAmplitude for voice reactivity
                            const baseHeight = 4.0;
                            final amplitudeFactor =
                                ((_currentAmplitude + 60) / 60).clamp(0.0, 1.0);
                            // Sine wave effect using tick and index offset
                            final phase =
                                (_animationTick + index * 2) * 3.14159 / 5;
                            final sineOffset =
                                (phase - phase.floor().toDouble()).abs() * 2 -
                                1;
                            final height =
                                baseHeight +
                                (8.0 * amplitudeFactor) +
                                (6.0 * (0.5 + 0.5 * sineOffset));
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 100),
                              margin: const EdgeInsets.only(right: 4),
                              width: 4,
                              height: height.clamp(4.0, 24.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }),
                        ),
                      ),
                    if (!_isRecording && !_isTranscribing)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          l10n.onboardingMicHint,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.textSub, fontSize: 10),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddLanguageDialog(BuildContext context, SettingsProvider settings) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Language'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter the language you want to translate the app into.',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'e.g. German, Spanish, Japanese',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final lang = controller.text.trim();
                  if (lang.isNotEmpty) {
                    Navigator.pop(context); // Close dialog
                    settings.addCustomLanguage(lang);
                  }
                },
                child: const Text('Translate'),
              ),
            ],
          ),
    );
  }
}
