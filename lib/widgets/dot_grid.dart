import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habits_provider.dart';
import '../theme.dart';

class DotGrid extends StatelessWidget {
  final Habit habit;
  final int days;
  final bool interactive; // false in stats screen

  const DotGrid({super.key, required this.habit, this.days = 182, this.interactive = true});

  String _key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayStr = _key(now);
    final color = Color(habit.color);

    final dayKeys = List.generate(days, (i) {
      final d = now.subtract(Duration(days: days - 1 - i));
      return _key(d);
    });

    return LayoutBuilder(builder: (context, constraints) {
      const cols = 26;
      const rows = 7;
      const gap = 2.5;
      final dotSize = (constraints.maxWidth - gap * (cols - 1)) / cols;

      return SizedBox(
        height: dotSize * rows + gap * (rows - 1),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: gap,
            crossAxisSpacing: gap,
          ),
          itemCount: cols * rows,
          itemBuilder: (context, index) {
            final col = index % cols;
            final row = index ~/ cols;
            final dayIndex = col * rows + row;
            if (dayIndex >= dayKeys.length) return const SizedBox();

            final k = dayKeys[dayIndex];
            final done = habit.completions[k] == true;
            final isToday = k == todayStr;
            // Future dots are not tappable
            final isFuture = k.compareTo(todayStr) > 0;

            Widget dot = AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: done ? color : AppTheme.muted2,
                borderRadius: BorderRadius.circular(2),
                border: isToday
                    ? Border.all(color: Colors.white.withOpacity(0.35), width: 1.2)
                    : null,
              ),
            );

            if (interactive && !isFuture) {
              dot = GestureDetector(
                onTap: () => _onDotTap(context, k, isToday, done),
                onLongPress: () => _onDotLongPress(context, k, done),
                child: dot,
              );
            }

            return dot;
          },
        ),
      );
    });
  }

  void _onDotTap(BuildContext context, String dateKey, bool isToday, bool done) {
    if (isToday) {
      // Today: just toggle directly
      context.read<HabitsProvider>().toggleDate(habit.id, dateKey);
    } else {
      // Past day: toggle with a quick haptic + snackbar confirmation
      HapticFeedback.lightImpact();
      context.read<HabitsProvider>().toggleDate(habit.id, dateKey);
      final label = _friendlyDate(dateKey);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            done ? 'Unmarked for $label' : 'Marked done for $label',
            style: const TextStyle(fontSize: 13),
          ),
          backgroundColor: AppTheme.surface2,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _onDotLongPress(BuildContext context, String dateKey, bool done) {
    // Long press shows a mini date popup for clarity
    HapticFeedback.mediumImpact();
    final label = _friendlyDate(dateKey);
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              habit.icon,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              done ? 'Completed ✓' : 'Not completed',
              style: TextStyle(
                fontSize: 13,
                color: done ? Color(habit.color) : AppTheme.textMuted,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<HabitsProvider>().toggleDate(habit.id, dateKey);
            },
            child: Text(
              done ? 'Mark incomplete' : 'Mark complete',
              style: TextStyle(color: Color(habit.color), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _friendlyDate(String key) {
    final d = DateTime.parse(key);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(d.year, d.month, d.day);
    final diff = today.difference(target).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[d.weekday - 1];
    }
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}';
  }
}
