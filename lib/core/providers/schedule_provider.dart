import 'package:flutter/material.dart';
import '../models/schedule_item.dart';
import '../services/storage_service.dart';

class ScheduleProvider extends ChangeNotifier {
  final StorageService _storageService;
  List<ScheduleItem> _schedule = [];
  bool _isLoading = false;

  ScheduleProvider(this._storageService);

  List<ScheduleItem> get schedule => _schedule;
  bool get isLoading => _isLoading;

  Future<void> loadSchedule() async {
    _isLoading = true;
    notifyListeners();

    try {
      _schedule = _storageService.loadSchedule();
    } catch (e) {
      debugPrint('Error loading schedule: $e');
      _schedule = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem(ScheduleItem item) async {
    _schedule.add(item);
    await _saveSchedule();
  }

  Future<void> removeItem(String id) async {
    _schedule.removeWhere((item) => item.id == id);
    await _saveSchedule();
  }

  Future<void> toggleTaken(String id) async {
    final index = _schedule.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = _schedule[index];
      _schedule[index] = ScheduleItem(
        id: item.id,
        medicationId: item.medicationId,
        medicationName: item.medicationName,
        timeSlot: item.timeSlot,
        isTaken: !item.isTaken,
        instructions: item.instructions,
      );
      await _saveSchedule();
    }
  }

  Future<void> _saveSchedule() async {
    try {
      await _storageService.saveSchedule(_schedule);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving schedule: $e');
    }
  }

  /// Adds a medication to the schedule by intelligently guessing the time slot
  /// based on the frequency string.
  /// Looks for hidden time tags like "{8pm}" or keywords.
  Future<void> addMedicationToSchedule(
    String medId,
    String medName,
    String frequency,
    String instructions,
  ) async {
    // 1. Check for specific hidden time tags {..}
    final timeTagRegex = RegExp(r'\{([^}]+)\}');
    final matches = timeTagRegex.allMatches(frequency);

    // If we find specific tags, use them
    if (matches.isNotEmpty) {
      for (final match in matches) {
        final timeStr = match.group(1)?.toLowerCase() ?? '';
        final slots = _parseTimeSlots(timeStr);
        for (final slot in slots) {
          await _addUniqueItem(medId, medName, slot, instructions);
        }
      }
      return;
    }

    // 2. Keyword matching if no tags
    final lowerFreq = frequency.toLowerCase();

    if (lowerFreq.contains('morning') ||
        lowerFreq.contains('breakfast') ||
        lowerFreq.contains('am')) {
      await _addUniqueItem(medId, medName, TimeSlot.morning, instructions);
    }

    if (lowerFreq.contains('noon') ||
        lowerFreq.contains('lunch') ||
        lowerFreq.contains('midday')) {
      await _addUniqueItem(medId, medName, TimeSlot.midday, instructions);
    }

    if (lowerFreq.contains('evening') ||
        lowerFreq.contains('dinner') ||
        lowerFreq.contains('supper') ||
        lowerFreq.contains('pm')) {
      await _addUniqueItem(medId, medName, TimeSlot.evening, instructions);
    }

    if (lowerFreq.contains('night') ||
        lowerFreq.contains('bed') ||
        lowerFreq.contains('sleep')) {
      await _addUniqueItem(medId, medName, TimeSlot.night, instructions);
    }

    // 3. Fallback: If nothing matched, default to Morning?
    // Or actually, if 'daily' is used, assume morning.
    if (_schedule.where((i) => i.medicationId == medId).isEmpty) {
      // Only add default if nothing else added
      await _addUniqueItem(medId, medName, TimeSlot.morning, instructions);
    }
  }

  List<TimeSlot> _parseTimeSlots(String timeStr) {
    // Simple parser for things like "8pm" or "morning" inside the brackets
    // Logic: Mapping hours to slots
    // Morning: 6-11
    // Midday: 11-4
    // Evening: 4-9
    // Night: 9-6

    final slots = <TimeSlot>{};
    final lower = timeStr.toLowerCase();

    // Keyword check inside format
    if (lower.contains('morning') || lower.contains('am'))
      slots.add(TimeSlot.morning);
    if (lower.contains('noon') || lower.contains('lunch'))
      slots.add(TimeSlot.midday);
    if (lower.contains('evening') ||
        lower.contains('dinner') ||
        lower.contains('pm'))
      slots.add(TimeSlot.evening);
    if (lower.contains('night') || lower.contains('bed'))
      slots.add(TimeSlot.night);

    // Specific hour check (simple check for now)
    // If we see "8pm", we map it.
    if (lower.contains('8pm') ||
        lower.contains('9pm') ||
        lower.contains('10pm'))
      slots.add(TimeSlot.night);
    if (lower.contains('5pm') || lower.contains('6pm') || lower.contains('7pm'))
      slots.add(TimeSlot.evening);

    if (slots.isEmpty) return [TimeSlot.morning]; // Fallback
    return slots.toList();
  }

  Future<void> _addUniqueItem(
    String medId,
    String name,
    TimeSlot slot,
    String instructions,
  ) async {
    // Avoid duplicates for same med in same slot
    final exists = _schedule.any(
      (i) => i.medicationId == medId && i.timeSlot == slot,
    );
    if (!exists) {
      final newItem = ScheduleItem(
        id:
            DateTime.now().millisecondsSinceEpoch.toString() +
            slot.toString(), // Simple unique ID
        medicationId: medId,
        medicationName: name,
        timeSlot: slot,
        isTaken: false,
        instructions: instructions,
      );
      await addItem(newItem);
    }
  }

  Future<void> removeItemsForMedication(String medicationId) async {
    _schedule.removeWhere((item) => item.medicationId == medicationId);
    await _saveSchedule();
  }

  /// Clears all schedule items
  Future<void> clearAll() async {
    _schedule.clear();
    await _saveSchedule();
  }
}
