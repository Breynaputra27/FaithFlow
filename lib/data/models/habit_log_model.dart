class HabitLog {
  final String id;
  final String userId;
  final String habitId;
  final DateTime completedAt;
  final String? note;
  final Map<String, dynamic>? value;

  HabitLog({
    required this.id,
    required this.userId,
    required this.habitId,
    required this.completedAt,
    this.note,
    this.value,
  });

  factory HabitLog.fromJson(Map<String, dynamic> json) {
    return HabitLog(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      habitId: json['habit_id'] as String,
      completedAt: DateTime.parse(json['completed_at'] as String),
      note: json['note'] as String?,
      value: json['value'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'habit_id': habitId,
      'completed_at': completedAt.toIso8601String(),
      'note': note,
      'value': value,
    };
  }

  HabitLog copyWith({
    String? id,
    String? userId,
    String? habitId,
    DateTime? completedAt,
    String? note,
    Map<String, dynamic>? value,
  }) {
    return HabitLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      habitId: habitId ?? this.habitId,
      completedAt: completedAt ?? this.completedAt,
      note: note ?? this.note,
      value: value ?? this.value,
    );
  }
}