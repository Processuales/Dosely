import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';

class ReadAloudButton extends StatelessWidget {
  const ReadAloudButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return TextButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('TTS coming soon!')));
      },
      icon: const Icon(Icons.volume_up, size: 20),
      label: Text(
        l10n.readAloud,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppTheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: AppTheme.surfaceAlt,
        foregroundColor: AppTheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.3)),
        ),
      ),
    );
  }
}
