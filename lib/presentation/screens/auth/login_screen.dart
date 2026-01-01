import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/services/supabase_service.dart';
import '../../providers/habit_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      if (_isLogin) {
        await SupabaseService.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        ref.invalidate(habitsProvider);
        ref.invalidate(todayCompletedHabitsProvider);
      } else {
        final response = await SupabaseService.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (response.user != null) {
          final userId = response.user!.id;
          final habitsToCreate = AppConstants.defaultPrayers
              .map((prayer) => {
                    'user_id': userId,
                    'habit_type': AppConstants.habitTypePrayer,
                    'name': 'Shalat $prayer',
                    'target_frequency': AppConstants.frequencyDaily,
                  })
              .toList();

          await SupabaseService.client.from('habits').insert(habitsToCreate);
          await Future.delayed(const Duration(milliseconds: 300));

          ref.invalidate(habitsProvider);
          ref.invalidate(todayCompletedHabitsProvider);
        }
      }

      HapticFeedback.heavyImpact();
    } catch (e) {
      if (mounted) {
        HapticFeedback.heavyImpact();

        // Parse error message untuk user-friendly text
        String errorMessage = _parseErrorMessage(e.toString());
        _showError(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  // Parse error message menjadi user-friendly
  String _parseErrorMessage(String error) {
    error = error.toLowerCase();

    // Login errors
    if (error.contains('invalid login credentials') ||
        error.contains('invalid email or password')) {
      return 'Email atau password salah';
    }

    if (error.contains('email not confirmed')) {
      return 'Email belum diverifikasi. Cek inbox Anda';
    }

    if (error.contains('user not found')) {
      return 'Akun tidak ditemukan';
    }

    // Register errors
    if (error.contains('user already registered') ||
        error.contains('email already exists')) {
      return 'Email sudah terdaftar. Silakan login';
    }

    if (error.contains('password should be at least')) {
      return 'Password minimal 6 karakter';
    }

    if (error.contains('invalid email')) {
      return 'Format email tidak valid';
    }

    // Network errors
    if (error.contains('network') || error.contains('connection')) {
      return 'Koneksi internet bermasalah. Coba lagi';
    }

    if (error.contains('timeout')) {
      return 'Koneksi timeout. Periksa internet Anda';
    }

    // Generic errors
    if (error.contains('unauthorized')) {
      return 'Akses tidak diizinkan';
    }

    // Default error message
    return 'Terjadi kesalahan. Coba lagi';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1a1a2e),
                    const Color(0xFF16213e),
                  ]
                : [
                    const Color(0xFFe8f5e9),
                    const Color(0xFFc8e6c9),
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Icon/Logo with animation
                    FadeInDown(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.2),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: _buildLogo(context),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // App Title
                    FadeInDown(
                      delay: const Duration(milliseconds: 100),
                      child: Text(
                        AppConstants.appName,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    FadeInDown(
                      delay: const Duration(milliseconds: 200),
                      child: Text(
                        _isLogin ? 'Masuk ke akun Anda' : 'Buat akun baru',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Email Field
                    FadeInLeft(
                      delay: const Duration(milliseconds: 300),
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.white.withValues(alpha: 0.7),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email harus diisi';
                          }
                          if (!value.contains('@')) {
                            return 'Email tidak valid';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    FadeInRight(
                      delay: const Duration(milliseconds: 400),
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              setState(
                                  () => _obscurePassword = !_obscurePassword);
                            },
                          ),
                          filled: true,
                          fillColor: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.white.withValues(alpha: 0.7),
                        ),
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password harus diisi';
                          }
                          if (value.length < 6) {
                            return 'Password minimal 6 karakter';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    FadeInUp(
                      delay: const Duration(milliseconds: 500),
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _authenticate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _isLogin ? 'Masuk' : 'Daftar',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Toggle Login/Register
                    FadeInUp(
                      delay: const Duration(milliseconds: 600),
                      child: TextButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() => _isLogin = !_isLogin);
                        },
                        child: Text(
                          _isLogin
                              ? 'Belum punya akun? Daftar'
                              : 'Sudah punya akun? Masuk',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Logo Widget - gunakan Image jika ada file logo
  Widget _buildLogo(BuildContext context) {
    // Coba load logo dari assets, kalau gagal pakai icon default
    return Image.asset(
      'assets/images/Logo.png',
      width: 80,
      height: 80,
      errorBuilder: (context, error, stackTrace) {
        // Fallback ke icon kalau logo tidak ada
        return Icon(
          Icons.mosque,
          size: 80,
          color: Theme.of(context).primaryColor,
        );
      },
    );
  }
}
