import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/models/medication.dart';
import '../../../core/providers/medication_provider.dart';
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
                              'No medications yet',
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

              // Export & Share Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('PDF export coming soon!'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                      label: Text(l10n.medsExport),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Share coming soon!')),
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: Text(l10n.medsShare),
                    ),
                  ],
                ),
              ),

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

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MedicationInformationScreen(medication: med),
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
                          med.frequency,
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
