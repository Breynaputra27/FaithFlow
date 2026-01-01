import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../data/models/habit_model.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final bool isCompleted;
  final VoidCallback onToggle;
  final VoidCallback? onLongPress;
  
  const HabitCard({
    super.key,
    required this.habit,
    required this.isCompleted,
    required this.onToggle,
    this.onLongPress,
  });
  
  IconData _getIcon() {
    switch (habit.habitType) {
      case 'prayer':
        return Icons.mosque;
      case 'quran':
        return Icons.book;
      case 'dzikir':
        return Icons.spa;
      case 'fasting':
        return Icons.restaurant;
      case 'sedekah':
        return Icons.volunteer_activism;
      default:
        return Icons.check_circle_outline;
    }
  }
  
  Color _getIconColor(BuildContext context) {
    if (isCompleted) {
      return Colors.white;
    }
    return Theme.of(context).primaryColor;
  }
  
  Color _getBackgroundColor(BuildContext context) {
    if (isCompleted) {
      return Theme.of(context).primaryColor;
    }
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[800]!
        : Colors.grey[200]!;
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isCompleted ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isCompleted
              ? LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha: 0.8),
                  ],
                )
              : null,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getBackgroundColor(context),
              shape: BoxShape.circle,
              boxShadow: isCompleted
                  ? [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              _getIcon(),
              color: _getIconColor(context),
              size: 24,
            ),
          )
              .animate(target: isCompleted ? 1 : 0)
              .scale(
                duration: 300.ms,
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
              )
              .then()
              .scale(
                duration: 300.ms,
                begin: const Offset(1.1, 1.1),
                end: const Offset(1, 1),
              ),
          title: Text(
            habit.name,
            style: TextStyle(
              decoration: isCompleted ? TextDecoration.lineThrough : null,
              color: isCompleted ? Colors.white : null,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.white.withValues(alpha: 0.3)
                        : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    habit.habitType.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isCompleted
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          trailing: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.white
                  : isDark
                      ? Colors.grey[700]
                      : Colors.grey[300],
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted
                    ? Colors.white
                    : Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            child: isCompleted
                ? Icon(
                    Icons.check,
                    size: 18,
                    color: Theme.of(context).primaryColor,
                  )
                    .animate()
                    .scale(
                      duration: 300.ms,
                      curve: Curves.elasticOut,
                    )
                : null,
          ),
          onTap: onToggle,
          onLongPress: onLongPress,
        ),
      ),
    )
        .animate(target: isCompleted ? 1 : 0)
        .shimmer(
          duration: 1000.ms,
          color: Colors.white.withValues(alpha: 0.3),
        );
  }
}