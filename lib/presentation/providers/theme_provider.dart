import 'package:flutter_riverpod/flutter_riverpod.dart';

// Theme Provider
final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false); // false = light mode, true = dark mode
  
  void toggle() {
    state = !state;
  }
  
  void setDarkMode(bool isDark) {
    state = isDark;
  }
}