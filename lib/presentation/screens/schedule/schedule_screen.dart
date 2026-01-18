import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/models/schedule_item.dart';
import '../../../core/providers/schedule_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/read_aloud_button.dart';

/// Schedule/Plan screen - shows medication schedule and conflict alerts
class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheduleProvider = context.watch<ScheduleProvider>();
    final scheduleItems = scheduleProvider.schedule;

    // Filter items by time slot
    final morningItems =
        scheduleItems.where((i) => i.timeSlot == TimeSlot.morning).toList();
    final middayItems =
        scheduleItems.where((i) => i.timeSlot == TimeSlot.midday).toList();
    final eveningItems =
        scheduleItems.where((i) => i.timeSlot == TimeSlot.evening).toList();
    final nightItems =
        scheduleItems.where((i) => i.timeSlot == TimeSlot.night).toList();

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
                    const Icon(
                      Icons.calendar_today,
                      size: 28,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.navSchedule,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                    const ReadAloudButton(),
                  ],
                ),
              ),

              // Title Section
              const SizedBox(height: 24), // Added padding
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.scheduleTitle,
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.scheduleReview,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSub),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /* 
              // Removed Demo Medication Card and Conflict Alert as per request to remove examples
              // Keeping them commented out if needed for future reference or reference implementation
              */

              // Daily Schedule Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  l10n.scheduleDaily,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),

              const SizedBox(height: 16),

              // Time Slots
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Morning
                    _buildTimeSlot(
                      context,
                      Icons.wb_sunny,
                      l10n.scheduleMorning,
                      Colors.amber,
                      items: morningItems,
                      l10n: l10n,
                    ),
                    const SizedBox(height: 12),
                    // Midday
                    _buildTimeSlot(
                      context,
                      Icons.wb_twilight,
                      l10n.scheduleMidday,
                      AppTheme.textLight,
                      items: middayItems,
                      l10n: l10n,
                    ),
                    const SizedBox(height: 12),
                    // Evening
                    _buildTimeSlot(
                      context,
                      Icons.nights_stay,
                      l10n.scheduleEvening,
                      AppTheme.textLight,
                      items: eveningItems,
                      l10n: l10n,
                    ),
                    const SizedBox(height: 12),
                    // Night
                    _buildTimeSlot(
                      context,
                      Icons.bedtime,
                      l10n.scheduleNight,
                      Colors.indigo,
                      items: nightItems,
                      l10n: l10n,
                    ),
                  ],
                ),
              ),

              if (scheduleItems.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'Your schedule is empty',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSub,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Add Another Medication Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Not implemented yet')),
                    );
                  },
                  icon: const Icon(Icons.add_circle),
                  label: Text(l10n.scheduleAddAnother),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSub,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: BorderSide(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 100), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlot(
    BuildContext context,
    IconData icon,
    String title,
    Color color, {
    required AppLocalizations l10n,
    List<ScheduleItem> items = const [],
  }) {
    final bool isActive = items.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? color.withValues(alpha: 0.5) : AppTheme.border,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: isActive ? color : AppTheme.textSub),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isActive ? AppTheme.textMain : AppTheme.textSub,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          if (isActive) ...[
            const SizedBox(height: 16),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildScheduleItem(context, item, l10n),
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              l10n.scheduleNoMeds,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSub,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleItem(
    BuildContext context,
    ScheduleItem item,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              context.read<ScheduleProvider>().toggleTaken(item.id);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: item.isTaken ? AppTheme.primary : AppTheme.textSub,
                  width: 2,
                ),
                color: item.isTaken ? AppTheme.primary : null,
              ),
              child:
                  item.isTaken
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.medicationName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration:
                        item.isTaken ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  item.instructions,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.textSub),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
