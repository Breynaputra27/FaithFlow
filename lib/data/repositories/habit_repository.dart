import '../models/habit_model.dart';
import '../models/habit_log_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // TAMBAHKAN INI

class HabitRepository {
  final SupabaseClient _supabase = Supabase.instance.client; // TAMBAHKAN INI

  // Get all active habits - GUNAKAN _supabase langsung
  Future<List<Habit>> getHabits() async {
    try {
      // GUNAKAN _supabase, bukan SupabaseService.getHabits()
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final response = await _supabase
          .from('habits')
          .select()
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('created_at');

      return response.map((json) => Habit.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch habits: $e');
    }
  }
  
  // Create new habit - GUNAKAN _supabase langsung
  Future<Habit> createHabit({
    required String habitType,
    required String name,
    String targetFrequency = 'daily',
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final response = await _supabase
          .from('habits')
          .insert({
            'user_id': userId,
            'habit_type': habitType,
            'name': name,
            'target_frequency': targetFrequency,
            'is_active': true,
          })
          .select()
          .single();

      return Habit.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create habit: $e');
    }
  }
  
  // Update habit - GUNAKAN _supabase langsung
  Future<void> updateHabit({
    required String habitId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _supabase.from('habits').update(updates).eq('id', habitId);
    } catch (e) {
      throw Exception('Failed to update habit: $e');
    }
  }
  
  // Delete habit - GUNAKAN _supabase langsung
  Future<void> deleteHabit(String habitId) async {
    try {
      await _supabase
          .from('habits')
          .update({'is_active': false})
          .eq('id', habitId);
    } catch (e) {
      throw Exception('Failed to delete habit: $e');
    }
  }
  
  // Log habit completion - GUNAKAN _supabase langsung
  Future<void> logHabit({
    required String habitId,
    String? note,
    Map<String, dynamic>? value,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      await _supabase.from('habit_logs').insert({
        'user_id': userId,
        'habit_id': habitId,
        'completed_at': DateTime.now().toIso8601String(),
        'note': note,
        'value': value,
      });
    } catch (e) {
      throw Exception('Failed to log habit: $e');
    }
  }
  
  // Remove habit log - GUNAKAN _supabase langsung
  Future<void> removeHabitLog({
    required String habitId,
    required DateTime date,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      await _supabase
          .from('habit_logs')
          .delete()
          .eq('user_id', userId)
          .eq('habit_id', habitId)
          .gte('completed_at', startOfDay.toIso8601String())
          .lt('completed_at', endOfDay.toIso8601String());
    } catch (e) {
      throw Exception('Failed to remove habit log: $e');
    }
  }
  
  // Get today's completed habits - GUNAKAN _supabase langsung
  Future<Map<String, bool>> getTodayCompletedHabits() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return {};

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final logs = await _supabase
          .from('habit_logs')
          .select('habit_id')
          .eq('user_id', userId)
          .gte('completed_at', startOfDay.toIso8601String())
          .lt('completed_at', endOfDay.toIso8601String());

      final Map<String, bool> completedHabits = {};
      
      for (var log in logs) {
        completedHabits[log['habit_id'] as String] = true;
      }
      
      return completedHabits;
    } catch (e) {
      throw Exception('Failed to fetch today logs: $e');
    }
  }
  
  // Get logs for date range - GUNAKAN _supabase langsung
  Future<List<HabitLog>> getLogsForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('habit_logs')
          .select()
          .eq('user_id', userId)
          .gte('completed_at', startDate.toIso8601String())
          .lte('completed_at', endDate.toIso8601String())
          .order('completed_at', ascending: false);

      return response.map((json) => HabitLog.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch logs: $e');
    }
  }
}