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
}
