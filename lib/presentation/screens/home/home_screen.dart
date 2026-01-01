import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'package:confetti/confetti.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/habit_model.dart';
import '../../../data/services/supabase_service.dart';
import '../../providers/habit_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/habit_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late ConfettiController _confettiController;
  
  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }
  
  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsProvider);
    final completedHabitsAsync = ref.watch(todayCompletedHabitsProvider);
    final isDark = ref.watch(themeProvider);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FadeInDown(
          child: const Text(
            AppConstants.appName,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            child: IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                HapticFeedback.lightImpact();
                ref.read(themeProvider.notifier).toggle();
              },
            ),
          ),
          FadeInDown(
            delay: const Duration(milliseconds: 200),
            child: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                HapticFeedback.mediumImpact();
                _showLogoutDialog();
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Gradient Background
          Container(
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
          ),
          
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
            ),
          ),
          
          // Content
          RefreshIndicator(
            onRefresh: () async {
              HapticFeedback.lightImpact();
              ref.invalidate(habitsProvider);
              ref.invalidate(todayCompletedHabitsProvider);
            },
            child: habitsAsync.when(
              data: (habits) {
                if (habits.isEmpty) {
                  return _buildEmptyState();
                }
                
                return completedHabitsAsync.when(
                  data: (completedHabits) => _buildHabitsList(habits, completedHabits),
                  loading: () => _buildShimmerLoading(),
                  error: (error, _) => _buildErrorState(error.toString()),
                );
              },
              loading: () => _buildShimmerLoading(),
              error: (error, _) => _buildErrorState(error.toString()),
            ),
          ),
        ],
      ),
      floatingActionButton: FadeInUp(
        delay: const Duration(milliseconds: 300),
        child: FloatingActionButton.extended(
          onPressed: () {
            HapticFeedback.mediumImpact();
            _showAddHabitDialog();
          },
          icon: const Icon(Icons.add),
          label: const Text('Tambah Habit'),
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: FadeInUp(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mosque,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Belum ada habit',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mulai tracking ibadah harianmu',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return FadeIn(
          delay: Duration(milliseconds: index * 100),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildErrorState(String error) {
    return Center(
      child: FadeIn(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Oops! Terjadi kesalahan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                ref.invalidate(habitsProvider);
                ref.invalidate(todayCompletedHabitsProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHabitsList(List habits, Map<String, bool> completedHabits) {
    final completedCount = completedHabits.length;
    final totalCount = habits.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
    
    // Trigger confetti when 100% complete
    if (progress == 1.0 && totalCount > 0) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _confettiController.play();
      });
    }
    
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 100, 16, 100),
      children: [
        // Hero Progress Card
        FadeInDown(
          child: _buildProgressCard(completedCount, totalCount, progress),
        ),
        
        const SizedBox(height: 24),
        
        // Date Header
        FadeInLeft(
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.now()),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Habits List with staggered animation
        ...List.generate(habits.length, (index) {
          final habit = habits[index];
          final isCompleted = completedHabits[habit.id] ?? false;
          
          return FadeInUp(
            delay: Duration(milliseconds: index * 50),
            child: HabitCard(
              habit: habit,
              isCompleted: isCompleted,
              onToggle: () => _toggleHabit(habit.id, isCompleted),
              onLongPress: () => _showHabitOptions(habit),
            ),
          );
        }),
      ],
    );
  }
  
  Widget _buildProgressCard(int completed, int total, double progress) {
    final isDark = ref.watch(themeProvider);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF2E7D32),
                  const Color(0xFF1B5E20),
                ]
              : [
                  const Color(0xFF4CAF50),
                  const Color(0xFF2E7D32),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Progress Hari Ini',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$completed dari $total habit',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              CircularPercentIndicator(
                radius: 50,
                lineWidth: 8,
                percent: progress,
                center: Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                progressColor: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                circularStrokeCap: CircularStrokeCap.round,
                animation: true,
                animationDuration: 1000,
              ),
            ],
          ),
          if (progress == 1.0 && total > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.celebration, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Alhamdulillah! Semua habit selesai!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Future<void> _toggleHabit(String habitId, bool currentStatus) async {
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    final repository = ref.read(habitRepositoryProvider);
    
    try {
      if (currentStatus) {
        await repository.removeHabitLog(
          habitId: habitId,
          date: DateTime.now(),
        );
      } else {
        await repository.logHabit(habitId: habitId);
      }
      
      ref.invalidate(todayCompletedHabitsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
  
  void _showHabitOptions(Habit habit) {
    HapticFeedback.mediumImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit Habit'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditHabitDialog(habit);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Hapus Habit', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(habit);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showEditHabitDialog(Habit habit) {
    final controller = TextEditingController(text: habit.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Habit'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nama Habit',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nama habit harus diisi')),
                );
                return;
              }
              
              if (controller.text == habit.name) {
                Navigator.pop(context);
                return;
              }
              
              try {
                HapticFeedback.mediumImpact();
                final repository = ref.read(habitRepositoryProvider);
                await repository.updateHabit(
                  habitId: habit.id,
                  updates: {'name': controller.text},
                );
                
                ref.invalidate(habitsProvider);
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Habit berhasil diupdate'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteConfirmation(Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Habit'),
        content: Text('Apakah Anda yakin ingin menghapus "${habit.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                HapticFeedback.heavyImpact();
                final repository = ref.read(habitRepositoryProvider);
                await repository.deleteHabit(habit.id);
                
                ref.invalidate(habitsProvider);
                ref.invalidate(todayCompletedHabitsProvider);
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Habit berhasil dihapus'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
  
  void _showAddHabitDialog() {
    final controller = TextEditingController();
    String selectedType = AppConstants.habitTypePrayer;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Tambah Habit Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipe Habit',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'prayer',
                    child: Row(
                      children: [
                        Icon(Icons.mosque, size: 20),
                        SizedBox(width: 8),
                        Text('Shalat'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'quran',
                    child: Row(
                      children: [
                        Icon(Icons.book, size: 20),
                        SizedBox(width: 8),
                        Text('Baca Quran'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'dzikir',
                    child: Row(
                      children: [
                        Icon(Icons.spa, size: 20),
                        SizedBox(width: 8),
                        Text('Dzikir'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'fasting',
                    child: Row(
                      children: [
                        Icon(Icons.restaurant, size: 20),
                        SizedBox(width: 8),
                        Text('Puasa'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'sedekah',
                    child: Row(
                      children: [
                        Icon(Icons.volunteer_activism, size: 20),
                        SizedBox(width: 8),
                        Text('Sedekah'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  setDialogState(() => selectedType = value!);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Nama Habit',
                  hintText: 'Misal: Shalat Dhuha',
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nama habit harus diisi')),
                  );
                  return;
                }
                
                try {
                  HapticFeedback.mediumImpact();
                  final repository = ref.read(habitRepositoryProvider);
                  await repository.createHabit(
                    habitType: selectedType,
                    name: controller.text,
                  );
                  
                  ref.invalidate(habitsProvider);
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Habit berhasil ditambahkan'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              HapticFeedback.heavyImpact();
              ref.invalidate(habitsProvider);
              ref.invalidate(todayCompletedHabitsProvider);
              
              await SupabaseService.signOut();
              
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}