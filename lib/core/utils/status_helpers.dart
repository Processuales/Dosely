import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

import '../models/medication.dart';

/// Helper methods for MedicationStatus
class StatusHelpers {
  static Color getStatusColor(MedicationStatus status) {
    switch (status) {
      case MedicationStatus.safe:
        return AppTheme.statusSafe;
      case MedicationStatus.caution:
        return AppTheme.statusCaution;
      case MedicationStatus.conflict:
        return AppTheme.statusConflict;
    }
  }

  static Color getStatusBackgroundColor(MedicationStatus status) {
    switch (status) {
      case MedicationStatus.safe:
        return AppTheme.statusSafeBg;
      case MedicationStatus.caution:
        return AppTheme.statusCautionBg;
      case MedicationStatus.conflict:
        return AppTheme.statusConflictBg;
    }
  }

  static IconData getStatusIcon(MedicationStatus status) {
    switch (status) {
      case MedicationStatus.safe:
        return Icons.medication;
      case MedicationStatus.caution:
        return Icons.medication_liquid;
      case MedicationStatus.conflict:
        return Icons.warning;
    }
  }

  static IconData getStatusBadgeIcon(MedicationStatus status) {
    switch (status) {
      case MedicationStatus.safe:
        return Icons.check_circle;
      case MedicationStatus.caution:
        return Icons.error;
      case MedicationStatus.conflict:
        return Icons.dangerous;
    }
  }
}
