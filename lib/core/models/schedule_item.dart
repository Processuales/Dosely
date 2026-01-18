enum TimeSlot { morning, midday, evening, night }

class ScheduleItem {
  final String id;
  final String medicationId;
  final String medicationName;
  final TimeSlot timeSlot;
  final bool isTaken;
  final String instructions;

  ScheduleItem({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.timeSlot,
    required this.isTaken,
    required this.instructions,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      id: json['id'] as String,
      medicationId: json['medicationId'] as String,
      medicationName: json['medicationName'] as String,
      timeSlot: TimeSlot.values.firstWhere(
        (e) => e.name == json['timeSlot'],
        orElse: () => TimeSlot.morning,
      ),
      isTaken: json['isTaken'] as bool,
      instructions: json['instructions'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'medicationName': medicationName,
      'timeSlot': timeSlot.name,
      'isTaken': isTaken,
      'instructions': instructions,
    };
  }
}
