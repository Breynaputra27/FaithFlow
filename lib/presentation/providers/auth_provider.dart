import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/services/supabase_service.dart';

// Auth State Provider
final authStateProvider = StreamProvider<AuthState>((ref) {
  return SupabaseService.authStateChanges;
});

// Current User Provider
final currentUserProvider = Provider<User?>((ref) {
  return SupabaseService.currentUser;
});