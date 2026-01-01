class Habit {
  final String id;
  final String userId;
  final String habitType;
  final String name;
  final String targetFrequency;
  final bool isActive;
  final DateTime createdAt;

  Habit({
    required this.id,
    required this.userId,
    required this.habitType,
    required this.name,
    required this.targetFrequency,
    required this.isActive,
    required this.createdAt,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      habitType: json['habit_type'] as String,
      name: json['name'] as String,
      targetFrequency: json['target_frequency'] as String? ?? 'daily',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'habit_type': habitType,
      'name': name,
      'target_frequency': targetFrequency,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Habit copyWith({
    String? id,
    String? userId,
    String? habitType,
    String? name,
    String? targetFrequency,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      habitType: habitType ?? this.habitType,
      name: name ?? this.name,
      targetFrequency: targetFrequency ?? this.targetFrequency,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}