import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../widgets/read_aloud_button.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/providers/medication_provider.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/providers/voice_provider.dart';
import '../../../core/services/ai_service.dart';

/// Settings screen - language, text size, voice, and app info
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isSimplifying = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppTheme.surface,
                      border: Border(
                        bottom: BorderSide(color: AppTheme.border, width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.settings, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.settingsTitle,
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                        ),
                        const ReadAloudButton(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Appearance Section
                  _buildSectionTitle(
                    context,
                    Icons.palette_outlined,
                    l10n.settingsAppearance,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        children: [
                          // High Contrast
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  l10n.settingsHighContrast,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              Switch(
                                value: settings.isHighContrast,
                                onChanged:
                                    (val) => settings.setHighContrast(val),
                                activeColor: AppTheme.primary,
                              ),
                            ],
                          ),
                          const Divider(height: 32),

                          // Colorblind Mode
                          ExpansionTile(
                            title: Text(
                              l10n.settingsColorblind,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            tilePadding: EdgeInsets.zero,
                            shape: const Border(),
                            collapsedShape: const Border(),
                            children: [
                              _buildRadioOptionTile(
                                context,
                                l10n.settingsColorblindNone,
                                0,
                                settings.colorblindMode,
                                settings,
                              ),
                              _buildRadioOptionTile(
                                context,
                                l10n.settingsColorblindProtanopia,
                                1,
                                settings.colorblindMode,
                                settings,
                              ),
                              _buildRadioOptionTile(
                                context,
                                l10n.settingsColorblindDeuteranopia,
                                2,
                                settings.colorblindMode,
                                settings,
                              ),
                              _buildRadioOptionTile(
                                context,
                                l10n.settingsColorblindTritanopia,
                                3,
                                settings.colorblindMode,
                                settings,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Language Section
                  _buildSectionTitle(
                    context,
                    Icons.language,
                    l10n.settingsLanguage,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: settings.locale.languageCode,
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem(
                              value: 'en',
                              child: Text('English'),
                            ),
                            const DropdownMenuItem(
                              value: 'fr',
                              child: Text('Français'),
                            ),
                            if (settings.locale.languageCode == 'x' &&
                                settings.customLanguageName != null)
                              DropdownMenuItem(
                                value: 'x',
                                child: Text(settings.customLanguageName!),
                              ),
                            DropdownMenuItem(
                              value: 'add_custom',
                              child: Row(
                                children: [
                                  Icon(Icons.add, size: 18),
                                  SizedBox(width: 8),
                                  Text(l10n.settingsAddLanguage),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == 'add_custom') {
                              _showAddLanguageDialog(context, settings, l10n);
                            } else if (value != null) {
                              settings.setLocale(Locale(value));
                            }
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Text Size Section
                  _buildSectionTitle(
                    context,
                    Icons.text_fields,
                    l10n.settingsTextSize,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceAlt,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          _buildTextSizeOption(
                            context,
                            l10n.settingsTextNormal,
                            0,
                            settings.textSizeIndex,
                            (index) => settings.setTextSize(index),
                          ),
                          _buildTextSizeOption(
                            context,
                            l10n.settingsTextLarge,
                            1,
                            settings.textSizeIndex,
                            (index) => settings.setTextSize(index),
                          ),
                          _buildTextSizeOption(
                            context,
                            l10n.settingsTextExtraLarge,
                            2,
                            settings.textSizeIndex,
                            (index) => settings.setTextSize(index),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Voice Settings Section
                  _buildSectionTitle(
                    context,
                    Icons.record_voice_over,
                    l10n.settingsVoice,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Voice',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(height: 12),
                          Consumer<VoiceProvider>(
                            builder:
                                (context, voiceProvider, _) => Row(
                                  children: [
                                    _buildVoiceOption(
                                      context,
                                      'Aria',
                                      0,
                                      voiceProvider.voiceIndex,
                                      voiceProvider,
                                    ),
                                    const SizedBox(width: 8),
                                    _buildVoiceOption(
                                      context,
                                      'Marcus',
                                      1,
                                      voiceProvider.voiceIndex,
                                      voiceProvider,
                                    ),
                                    const SizedBox(width: 8),
                                    _buildVoiceOption(
                                      context,
                                      'Sophia',
                                      2,
                                      voiceProvider.voiceIndex,
                                      voiceProvider,
                                    ),
                                  ],
                                ),
                          ),
                          const SizedBox(height: 16),
                          Consumer<VoiceProvider>(
                            builder:
                                (
                                  context,
                                  voiceProvider,
                                  _,
                                ) => OutlinedButton.icon(
                                  onPressed:
                                      voiceProvider.isLoading ||
                                              voiceProvider.isPlaying
                                          ? null
                                          : () {
                                            voiceProvider.readAloud(
                                              'This is a test of the ${voiceProvider.selectedVoiceName} voice. Hello, I am your medication assistant.',
                                              settings.locale.languageCode,
                                            );
                                          },
                                  icon: Icon(
                                    voiceProvider.isPlaying
                                        ? Icons.stop
                                        : Icons.play_arrow,
                                  ),
                                  label: Text(
                                    voiceProvider.isLoading
                                        ? 'Loading...'
                                        : voiceProvider.isPlaying
                                        ? 'Stop'
                                        : l10n.settingsTestVoice,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(
                                      double.infinity,
                                      48,
                                    ),
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Simple Mode Toggle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.settingsSimpleMode,
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.settingsSimpleModeSubtitle,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                if (_isSimplifying)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 12,
                                          height: 12,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          l10n.settingsSimplifying,
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Switch(
                            value: settings.simpleMode,
                            onChanged:
                                _isSimplifying
                                    ? null
                                    : (value) async {
                                      settings.setSimpleMode(value);

                                      // If turning ON simple mode, simplify existing medications
                                      if (value) {
                                        setState(() => _isSimplifying = true);

                                        final medProvider =
                                            context.read<MedicationProvider>();
                                        final aiService = AIService();

                                        try {
                                          await medProvider
                                              .simplifyAllMedications(
                                                aiService
                                                    .simplifyMedicationInfo,
                                                languageCode:
                                                    settings
                                                        .locale
                                                        .languageCode,
                                              );
                                        } catch (e) {
                                          debugPrint('Error simplifying: $e');
                                        }

                                        if (mounted) {
                                          setState(
                                            () => _isSimplifying = false,
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).clearSnackBars();
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                l10n.settingsSimplified,
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                            activeThumbColor: AppTheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Clear History Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.settingsHistoryCleared)),
                        );
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: Text(l10n.settingsClearHistory),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.statusConflict,
                        side: const BorderSide(color: AppTheme.statusConflict),
                      ),
                    ),
                  ),

                  const Divider(height: 48),

                  // Info Links
                  _buildInfoLink(
                    context,
                    Icons.info_outline,
                    l10n.settingsAbout,
                  ),
                  _buildInfoLink(
                    context,
                    Icons.description_outlined,
                    l10n.settingsDisclaimer,
                  ),
                  _buildInfoLink(
                    context,
                    Icons.lock_outline,
                    l10n.settingsPrivacy,
                  ),

                  const SizedBox(height: 100), // Bottom padding for nav bar
                ],
              ),
            ),
          ),

          // Loading Overlay
          if (settings.isLanguageLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Translating Application...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Converting labels, tags and content.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddLanguageDialog(
    BuildContext context,
    SettingsProvider settings,
    AppLocalizations l10n,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.settingsAddLanguage),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.settingsEnterLanguage),
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
                child: Text(l10n.dialogCancel),
              ),
              ElevatedButton(
                onPressed: () {
                  final lang = controller.text.trim();
                  if (lang.isNotEmpty) {
                    Navigator.pop(context); // Close dialog
                    settings.addCustomLanguage(
                      lang,
                      onLanguageAdded: (addedLang) async {
                        final profileProvider = context.read<ProfileProvider>();
                        final aiService = AIService();
                        await profileProvider.translateProfileData(
                          (list) => aiService.translateList(list, addedLang),
                        );
                      },
                    );
                  }
                },
                child: Text(l10n.settingsTranslate),
              ),
            ],
          ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textLight),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextSizeOption(
    BuildContext context,
    String label,
    int index,
    int selectedIndex,
    Function(int) onTap,
  ) {
    final isSelected = index == selectedIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: isSelected ? AppTheme.primary : AppTheme.textLight,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceOption(
    BuildContext context,
    String label,
    int index,
    int selectedIndex,
    VoiceProvider voiceProvider,
  ) {
    final isSelected = index == selectedIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => voiceProvider.setVoice(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : AppTheme.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primary : AppTheme.border,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: isSelected ? Colors.white : AppTheme.textSub,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoLink(BuildContext context, IconData icon, String title) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$title coming soon!')));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 24, color: AppTheme.textLight),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textLight),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOptionTile(
    BuildContext context,
    String title,
    int value,
    int groupValue,
    SettingsProvider settings,
  ) {
    return RadioListTile<int>(
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
      value: value,
      groupValue: groupValue,
      onChanged: (val) {
        if (val != null) {
          settings.setColorblindMode(val);
        }
      },
      activeColor: AppTheme.primary,
      contentPadding: EdgeInsets.zero,
    );
  }
}
