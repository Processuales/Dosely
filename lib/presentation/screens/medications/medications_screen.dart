import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/models/medication.dart';
import '../../../core/providers/medication_provider.dart';
import '../../../core/providers/schedule_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/status_helpers.dart';

import '../../widgets/read_aloud_button.dart';
import '../side_effects/medication_information_screen.dart';

/// Medications list screen - shows all saved medications
class MedicationsScreen extends StatelessWidget {
  const MedicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final medicationProvider = context.watch<MedicationProvider>();
    final activeMeds = medicationProvider.medications;

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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.medication,
                            size: 28,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              l10n.medsTitle,
                              style: Theme.of(context).textTheme.headlineLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Read aloud button
                    // Read aloud button
                    const ReadAloudButton(),
                  ],
                ),
              ),
              // Swipe hint - centered and more visible
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back, size: 14, color: Colors.red[400]),
                    const SizedBox(width: 4),
                    Text(
                      l10n.actionDelete,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.swipe, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 16),
                    Text(
                      l10n.actionSchedule,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: Colors.green[600],
                    ),
                  ],
                ),
              ),

              // Active Medications Section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Row(
                  children: [
                    Text(
                      l10n.medsActive,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${activeMeds.length}',
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Medication Cards List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child:
                    activeMeds.isEmpty
                        ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(
                              l10n.medsNoneYet,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: AppTheme.textSub),
                            ),
                          ),
                        )
                        : Column(
                          children:
                              activeMeds
                                  .map(
                                    (med) => Column(
                                      children: [
                                        _buildMedicationListItem(
                                          context,
                                          med,
                                          _getDaysAgo(
                                            context,
                                            DateTime.now()
                                                .difference(med.dateScanned)
                                                .inDays,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                    ),
                                  )
                                  .toList(),
                        ),
              ),

              const SizedBox(height: 32),

              const SizedBox(height: 100), // Bottom padding for nav bar
            ],
          ),
        ),
      ),
    );
  }

  String _getDaysAgo(BuildContext context, int days) {
    return AppLocalizations.of(context)!.medsDaysAgo(days);
  }

  Widget _buildMedicationListItem(
    BuildContext context,
    Medication med,
    String lastScan,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return Dismissible(
      key: Key(med.id),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.calendar_today, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Delete direction
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(l10n.medsDeleteTitle),
                content: Text(l10n.medsDeleteConfirm(med.name)),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(l10n.dialogCancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      l10n.actionDelete,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              );
            },
          );
        } else {
          // Schedule direction - Add to schedule
          await context.read<ScheduleProvider>().addMedicationToSchedule(
            med.id,
            med.name,
            med.frequency,
            med.instructions,
          );

          if (context.mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.medsAddedScheduleItem(med.name)),
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return false; // Don't remove from list
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          context.read<MedicationProvider>().removeMedication(med.id);
          context.read<ScheduleProvider>().removeItemsForMedication(med.id);

          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.medsRemovedItem(med.name)),
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: l10n.actionUndo,
                onPressed: () {
                  context.read<MedicationProvider>().addMedication(med);
                },
              ),
            ),
          );
        }
      },
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => MedicationInformationScreen(medication: med),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
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
              Row(
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: StatusHelpers.getStatusBackgroundColor(med.status),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      StatusHelpers.getStatusIcon(med.status),
                      size: 24,
                      color: StatusHelpers.getStatusColor(med.status),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          med.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          med.dosage,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  _buildStatusBadge(context, med.status),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 16,
                          color: AppTheme.textLight,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            med.frequency
                                .replaceAll(RegExp(r'\{[^}]+\}'), '')
                                .trim(),
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${l10n.medsLastScan}: $lastScan',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, MedicationStatus status) {
    String text;
    switch (status) {
      case MedicationStatus.safe:
        text = 'SAFE';
        break;
      case MedicationStatus.caution:
        text = 'CAUTION';
        break;
      case MedicationStatus.conflict:
        text = 'CONFLICT';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: StatusHelpers.getStatusBackgroundColor(status),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: StatusHelpers.getStatusColor(status).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            StatusHelpers.getStatusBadgeIcon(status),
            size: 14,
            color: StatusHelpers.getStatusColor(status),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: StatusHelpers.getStatusColor(status),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
