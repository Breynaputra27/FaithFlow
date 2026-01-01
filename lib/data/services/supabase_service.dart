import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Getter for client
  static SupabaseClient get client => _client;

  // Auth Methods
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static User? get currentUser => _client.auth.currentUser;

  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  // Habit Methods
  static Future<List<Map<String, dynamic>>> getHabits() async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final response = await _client
        .from('habits')
        .select()
        .eq('user_id', userId)
        .eq('is_active', true)
        .order('created_at');

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<Map<String, dynamic>> createHabit({
    required String habitType,
    required String name,
    String targetFrequency = 'daily',
  }) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final response = await _client
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

    return response;
  }

  static Future<void> updateHabit({
    required String habitId,
    required Map<String, dynamic> updates,
  }) async {
    await _client.from('habits').update(updates).eq('id', habitId);
  }

  static Future<void> deleteHabit(String habitId) async {
    await _client.from('habits').update({'is_active': false}).eq('id', habitId);
  }

  // Habit Log Methods - SIMPLIFIED VERSION
  static Future<void> logHabit({
    required String habitId,
    String? note,
    Map<String, dynamic>? value,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    await _client.from('habit_logs').insert({
      'user_id': userId,
      'habit_id': habitId,
      'completed_at': DateTime.now().toIso8601String(),
      'note': note,
      'value': value,
    });
  }

  static Future<void> deleteHabitLog({
    required String habitId,
    required DateTime date,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    await _client
        .from('habit_logs')
        .delete()
        .eq('user_id', userId)
        .eq('habit_id', habitId)
        .gte('completed_at', startOfDay.toIso8601String())
        .lt('completed_at', endOfDay.toIso8601String());
  }

  static Future<List<Map<String, dynamic>>> getTodayLogs() async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final response = await _client
        .from('habit_logs')
        .select()
        .eq('user_id', userId)
        .gte('completed_at', startOfDay.toIso8601String())
        .lt('completed_at', endOfDay.toIso8601String())
        .order('completed_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<Map<String, dynamic>>> getLogsForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final response = await _client
        .from('habit_logs')
        .select()
        .eq('user_id', userId)
        .gte('completed_at', startDate.toIso8601String())
        .lte('completed_at', endDate.toIso8601String())
        .order('completed_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Simple debug method
  static Future<List<Map<String, dynamic>>> getAllLogs() async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final response = await _client
        .from('habit_logs')
        .select()
        .eq('user_id', userId)
        .order('completed_at', ascending: false)
        .limit(50);

    return List<Map<String, dynamic>>.from(response);
  }
}