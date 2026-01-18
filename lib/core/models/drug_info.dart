import 'package:equatable/equatable.dart';

enum MedicationStatus { safe, caution, conflict }

enum MedicationType { tablet, liquid, injection, inhaler, other }

/// Represents the persistent knowledge about a drug, independent of a user's specific prescription.
class DrugInfo extends Equatable {
  final String id; // Computed from normalized name usually
  final String name;
  final MedicationType type;
  final String? shortDescription;
  final String? longDescription;
  final String? conflictDescription;
  final String? statusReason; // Explains why status is caution/conflict
  final List<String> commonSideEffects;

  // Simplified versions for "Explain Like I'm 12" mode
  final String? shortDescriptionSimplified;
  final String? longDescriptionSimplified;
  final List<String>? commonSideEffectsSimplified;
  final String? statusReasonSimplified;
  final String? conflictDescriptionSimplified;

  final String? defaultDosage;
  final String? lastKnownFrequency; // Learned from user
  final String? lastKnownInstructions; // Learned from user

  const DrugInfo({
    required this.id,
    required this.name,
    required this.type,
    this.shortDescription,
    this.longDescription,
    this.conflictDescription,
    this.statusReason,
    this.commonSideEffects = const [],
    this.shortDescriptionSimplified,
    this.longDescriptionSimplified,
    this.commonSideEffectsSimplified,
    this.statusReasonSimplified,
    this.conflictDescriptionSimplified,
    this.defaultDosage,
    this.lastKnownFrequency,
    this.lastKnownInstructions,
  });

  factory DrugInfo.fromJson(Map<String, dynamic> json) {
    return DrugInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      type: MedicationType.values.firstWhere(
        (e) => e.name == (json['type'] ?? 'tablet'),
        orElse: () => MedicationType.tablet,
      ),
      shortDescription: json['shortDescription'] as String?,
      longDescription: json['longDescription'] as String?,
      conflictDescription: json['conflictDescription'] as String?,
      statusReason: json['statusReason'] as String?,
      commonSideEffects:
          (json['commonSideEffects'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      shortDescriptionSimplified: json['shortDescriptionSimplified'] as String?,
      longDescriptionSimplified: json['longDescriptionSimplified'] as String?,
      commonSideEffectsSimplified:
          (json['commonSideEffectsSimplified'] as List?)
              ?.map((e) => e.toString())
              .toList(),
      statusReasonSimplified: json['statusReasonSimplified'] as String?,
      conflictDescriptionSimplified:
          json['conflictDescriptionSimplified'] as String?,
      defaultDosage: json['defaultDosage'] as String?,
      lastKnownFrequency: json['lastKnownFrequency'] as String?,
      lastKnownInstructions: json['lastKnownInstructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'shortDescription': shortDescription,
      'longDescription': longDescription,
      'conflictDescription': conflictDescription,
      'statusReason': statusReason,
      'commonSideEffects': commonSideEffects,
      'shortDescriptionSimplified': shortDescriptionSimplified,
      'longDescriptionSimplified': longDescriptionSimplified,
      'commonSideEffectsSimplified': commonSideEffectsSimplified,
      'statusReasonSimplified': statusReasonSimplified,
      'conflictDescriptionSimplified': conflictDescriptionSimplified,
      'defaultDosage': defaultDosage,
      'lastKnownFrequency': lastKnownFrequency,
      'lastKnownInstructions': lastKnownInstructions,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    shortDescription,
    longDescription,
    conflictDescription,
    commonSideEffects,
    defaultDosage,
  ];
}
