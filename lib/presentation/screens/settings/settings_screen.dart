import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../widgets/read_aloud_button.dart';
import '../../../core/providers/settings_provider.dart';

/// Settings screen - language, text size, voice, and app info
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      body: SafeArea(
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
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'fr', child: Text('Français')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
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
                        'Speed',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildVoiceSpeedOption(
                            context,
                            l10n.settingsVoiceSlow,
                            0,
                            settings.voiceSpeedIndex,
                            (index) => settings.setVoiceSpeed(index),
                          ),
                          const SizedBox(width: 8),
                          _buildVoiceSpeedOption(
                            context,
                            l10n.settingsVoiceNormal,
                            1,
                            settings.voiceSpeedIndex,
                            (index) => settings.setVoiceSpeed(index),
                          ),
                          const SizedBox(width: 8),
                          _buildVoiceSpeedOption(
                            context,
                            l10n.settingsVoiceFast,
                            2,
                            settings.voiceSpeedIndex,
                            (index) => settings.setVoiceSpeed(index),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('TTS test coming soon!'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: Text(l10n.settingsTestVoice),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
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
                          ],
                        ),
                      ),
                      Switch(
                        value: settings.simpleMode,
                        onChanged: (value) => settings.setSimpleMode(value),
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
                      const SnackBar(content: Text('History cleared!')),
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
              _buildInfoLink(context, Icons.info_outline, l10n.settingsAbout),
              _buildInfoLink(
                context,
                Icons.description_outlined,
                l10n.settingsDisclaimer,
              ),
              _buildInfoLink(context, Icons.lock_outline, l10n.settingsPrivacy),

              const SizedBox(height: 100), // Bottom padding for nav bar
            ],
          ),
        ),
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

  Widget _buildVoiceSpeedOption(
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
}
