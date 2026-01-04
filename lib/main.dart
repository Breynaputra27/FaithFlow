import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';

void main() async {
  // Pastikan binding Flutter sudah siap sebelum menjalankan proses async
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi format tanggal untuk lokalisasi Indonesia
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi Supabase dengan proteksi try-catch agar tidak crash di awal (entry point)
  try {
    await Supabase.initialize(
      url: 'https://ueeiizhxhsfdtuomtusl.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVlZWlpemh4aHNmZHR1b210dXNsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU2NzE0MTksImV4cCI6MjA4MTI0NzQxOX0.NOK-emR6ZPpmTcGViW-JZpLvIrirkK5f3X5h512Ksr8',
    );
  } catch (e) {
    // Jika gagal (karena internet atau kunci salah), cetak error ke log tanpa mematikan aplikasi
    debugPrint("Supabase Initialization Error: $e");
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Habit Tracker Islami',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: authState.when(
        data: (auth) =>
            auth.session != null ? const HomeScreen() : const LoginScreen(),
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        // Jika terjadi error pada state auth, arahkan ke LoginScreen alih-alih crash
        error: (err, stack) {
          debugPrint("Auth State Error: $err");
          return const LoginScreen();
        },
      ),
    );
  }
}
