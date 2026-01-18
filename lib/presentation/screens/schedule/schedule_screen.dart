import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../core/localization/app_localizations.dart';
import '../../../core/models/schedule_item.dart';
import '../../../core/providers/schedule_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/read_aloud_button.dart';

/// Schedule/Plan screen - shows medication schedule and conflict alerts
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  Timer? _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Update every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Get the next upcoming time slot based on current time
  TimeSlot? _getNextTimeSlot() {
    final hour = _currentTime.hour;

    // Morning: 6-11, Midday: 11-16, Evening: 16-21, Night: 21-6
    if (hour >= 6 && hour < 11) {
      return TimeSlot.midday; // Next is midday
    } else if (hour >= 11 && hour < 16) {
      return TimeSlot.evening; // Next is evening
    } else if (hour >= 16 && hour < 21) {
      return TimeSlot.night; // Next is night
    } else {
      return TimeSlot.morning; // Next is morning (wraps around)
    }
  }

  /// Get approximate minutes until next time slot
  int _getMinutesUntilNext() {
    final hour = _currentTime.hour;
    final minute = _currentTime.minute;

    int targetHour;
    if (hour >= 6 && hour < 11) {
      targetHour = 11; // Midday starts at 11
    } else if (hour >= 11 && hour < 16) {
      targetHour = 16; // Evening starts at 16
    } else if (hour >= 16 && hour < 21) {
      targetHour = 21; // Night starts at 21
    } else if (hour >= 21) {
      targetHour = 30; // Morning at 6 (next day = 24 + 6 = 30)
    } else {
      targetHour = 6; // Morning starts at 6
    }

    final minutesUntil = ((targetHour - hour) * 60) - minute;
    return minutesUntil > 0 ? minutesUntil : 0;
  }

  String _formatMinutes(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins > 0) {
        return '$hours hr $mins min';
      }
      return '$hours hr';
    }
    return '$minutes min';
  }

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

    // Find next upcoming slot with medications
    final nextSlot = _getNextTimeSlot();
    final minutesUntil = _getMinutesUntilNext();

    // Check if next slot has medications
    bool hasNextMedication = false;
    String nextSlotName = '';
    if (nextSlot == TimeSlot.morning && morningItems.isNotEmpty) {
      hasNextMedication = true;
      nextSlotName = l10n.scheduleMorning;
    } else if (nextSlot == TimeSlot.midday && middayItems.isNotEmpty) {
      hasNextMedication = true;
      nextSlotName = l10n.scheduleMidday;
    } else if (nextSlot == TimeSlot.evening && eveningItems.isNotEmpty) {
      hasNextMedication = true;
      nextSlotName = l10n.scheduleEvening;
    } else if (nextSlot == TimeSlot.night && nightItems.isNotEmpty) {
      hasNextMedication = true;
      nextSlotName = l10n.scheduleNight;
    }

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

              // Next Medication Timer Card
              if (scheduleItems.isNotEmpty)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.timer,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasNextMedication
                                  ? l10n.scheduleNextInDetail(
                                    _formatMinutes(minutesUntil),
                                  )
                                  : l10n.scheduleNoUpcoming,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (hasNextMedication)
                              Text(
                                nextSlotName,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Title Section
              Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: scheduleItems.isEmpty ? 24 : 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      l10n.scheduleTitle,
                      style: Theme.of(context).textTheme.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.scheduleReview,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSub),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

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
                      l10n.scheduleEmpty,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSub,
                        fontStyle: FontStyle.italic,
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
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (direction) {
        context.read<ScheduleProvider>().removeItem(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.scheduleRemovedItem(item.medicationName)),
            duration: const Duration(seconds: 3),
          ),
        );
      },
      child: Container(
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
      ),
    );
  }
}
