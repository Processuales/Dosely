import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/voice_provider.dart';
import '../../core/theme/app_theme.dart';

/// Read Aloud button with ElevenLabs TTS integration
/// If pageContent is not provided, uses a generic context summary
class ReadAloudButton extends StatelessWidget {
  final String? pageContent;

  const ReadAloudButton({super.key, this.pageContent});

  String _getDefaultContent(BuildContext context) {
    // Build a description from app context for AI to narrate
    final route = ModalRoute.of(context)?.settings.name ?? 'Home';
    return '''
This is the $route screen of a medication safety app.
The screen shows navigation options and content related to managing medications, viewing schedules, and checking health profiles.
''';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final voiceProvider = context.watch<VoiceProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    final isLoading = voiceProvider.isLoading;
    final isPlaying = voiceProvider.isPlaying;

    return TextButton.icon(
      onPressed: () {
        if (isPlaying) {
          voiceProvider.stop();
        } else if (!isLoading) {
          final content = pageContent ?? _getDefaultContent(context);
          voiceProvider.readAloud(
            content,
            settingsProvider.locale.languageCode,
          );
        }
      },
      icon:
          isLoading
              ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primary,
                ),
              )
              : Icon(
                isPlaying ? Icons.stop : Icons.volume_up,
                size: 20,
                color: isPlaying ? Colors.red : AppTheme.primary,
              ),
      label: Text(
        isLoading
            ? 'Loading...'
            : isPlaying
            ? 'Stop'
            : l10n.readAloud,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: isPlaying ? Colors.red : AppTheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor:
            isPlaying ? Colors.red.withValues(alpha: 0.1) : AppTheme.surfaceAlt,
        foregroundColor: isPlaying ? Colors.red : AppTheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color:
                isPlaying
                    ? Colors.red.withValues(alpha: 0.3)
                    : AppTheme.primary.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
