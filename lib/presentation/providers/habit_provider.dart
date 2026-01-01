import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/habit_model.dart';
import '../../data/repositories/habit_repository.dart';

// Repository Provider
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepository();
});

// Habits List Provider
final habitsProvider = FutureProvider<List<Habit>>((ref) async {
  final repository = ref.watch(habitRepositoryProvider);
  try {
    return await repository.getHabits();
  } catch (e) {
    throw Exception('Failed to load habits: $e');
  }
});

// Today's Completed Habits Provider
final todayCompletedHabitsProvider = FutureProvider<Map<String, bool>>((ref) async {
  final repository = ref.watch(habitRepositoryProvider);
  try {
    return await repository.getTodayCompletedHabits();
  } catch (e) {
    throw Exception('Failed to load completed habits: $e');
  }
});