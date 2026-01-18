import 'package:flutter/material.dart';

import '../../core/models/medication.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/status_helpers.dart';
import '../../core/localization/app_localizations.dart';

/// Card showing a medication with status indicator
class MedicationCard extends StatelessWidget {
  final String name;
  final String dosage;
  final String timeAgo;
  final MedicationStatus status;
  final VoidCallback? onTap;

  const MedicationCard({
    super.key,
    required this.name,
    required this.dosage,
    required this.timeAgo,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  status == MedicationStatus.conflict
                      ? AppTheme.statusConflict.withValues(alpha: 0.3)
                      : AppTheme.border,
              width: status == MedicationStatus.conflict ? 2 : 1,
            ),
            // Left border accent for conflict
            boxShadow:
                status == MedicationStatus.conflict
                    ? [
                      BoxShadow(
                        color: AppTheme.statusConflict.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: StatusHelpers.getStatusBackgroundColor(status),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(
                  StatusHelpers.getStatusIcon(status),
                  size: 28,
                  color: StatusHelpers.getStatusColor(status),
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.headlineSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$dosage • $timeAgo',
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: StatusHelpers.getStatusBackgroundColor(status),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: StatusHelpers.getStatusColor(
                      status,
                    ).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      StatusHelpers.getStatusBadgeIcon(status),
                      size: 16,
                      color: StatusHelpers.getStatusColor(status),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getStatusText(l10n),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: StatusHelpers.getStatusColor(status),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(AppLocalizations l10n) {
    switch (status) {
      case MedicationStatus.safe:
        return l10n.statusSafeBadge;
      case MedicationStatus.caution:
        return l10n.statusCautionBadge;
      case MedicationStatus.conflict:
        return l10n.statusConflictBadge;
    }
  }
}
