class UserProfile {
  final String name;
  final String pronouns;
  final int age;
  final String sex;
  final bool isPregnant;
  final List<String> allergies;
  final List<String> conditions;
  final String medicalNotes;
  final DateTime memberSince;

  UserProfile({
    required this.name,
    required this.pronouns,
    required this.age,
    required this.sex,
    required this.isPregnant,
    required this.allergies,
    required this.conditions,
    this.medicalNotes = '',
    required this.memberSince,
  });

  factory UserProfile.empty() {
    return UserProfile(
      name: '',
      pronouns: '',
      age: 0,
      sex: '',
      isPregnant: false,
      allergies: [],
      conditions: [],
      medicalNotes: '',
      memberSince: DateTime.now(),
    );
  }

  UserProfile copyWith({
    String? name,
    String? pronouns,
    int? age,
    String? sex,
    bool? isPregnant,
    List<String>? allergies,
    List<String>? conditions,
    String? medicalNotes,
    DateTime? memberSince,
  }) {
    return UserProfile(
      name: name ?? this.name,
      pronouns: pronouns ?? this.pronouns,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      isPregnant: isPregnant ?? this.isPregnant,
      allergies: allergies ?? this.allergies,
      conditions: conditions ?? this.conditions,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      memberSince: memberSince ?? this.memberSince,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      pronouns: json['pronouns'] as String,
      age: json['age'] as int,
      sex: json['sex'] as String,
      isPregnant: json['isPregnant'] as bool,
      allergies: (json['allergies'] as List<dynamic>).cast<String>(),
      conditions: (json['conditions'] as List<dynamic>).cast<String>(),
      medicalNotes: json['medicalNotes'] as String? ?? '',
      memberSince: DateTime.parse(json['memberSince'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'pronouns': pronouns,
      'age': age,
      'sex': sex,
      'isPregnant': isPregnant,
      'allergies': allergies,
      'conditions': conditions,
      'medicalNotes': medicalNotes,
      'memberSince': memberSince.toIso8601String(),
    };
  }

  bool get isEmpty => name.isEmpty && age == 0;
}
