import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habits_provider.dart';
import '../theme.dart';
import '../widgets/dot_grid.dart';
import '../widgets/add_habit_sheet.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;

  const HabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final color = Color(habit.color);
    final provider = context.read<HabitsProvider>();

    return Dismissible(
      key: Key(habit.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppTheme.surface2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Remove habit', style: TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
            content: Text(
              'Delete "${habit.name}"? All history will be lost.',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => provider.deleteHabit(habit.id),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onLongPress: () => _editSheet(context),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      // Icon
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(habit.icon, style: const TextStyle(fontSize: 18)),
                      ),
                      const SizedBox(width: 10),
                      // Name + streak
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.name,
                              style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            _streakLabel(habit, color),
                          ],
                        ),
                      ),
                      // Check button
                      _CheckButton(habit: habit),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Dot grid
                  DotGrid(habit: habit),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _editSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddHabitSheet(existing: habit),
    );
  }

  Widget _streakLabel(Habit habit, Color color) {
    final s = habit.currentStreak;
    if (s == 0) {
      return const Text(
        'No streak yet',
        style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
      );
    }
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$s',
            style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: color,
              fontFamily: 'monospace',
            ),
          ),
          const TextSpan(
            text: ' day streak',
            style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}

class _CheckButton extends StatefulWidget {
  final Habit habit;
  const _CheckButton({required this.habit});

  @override
  State<_CheckButton> createState() => _CheckButtonState();
}

class _CheckButtonState extends State<_CheckButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final done = widget.habit.isDoneToday;
    final color = Color(widget.habit.color);
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        context.read<HabitsProvider>().toggleToday(widget.habit.id);
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: done ? color : color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: done ? 1.0 : 0.4,
            child: const Icon(Icons.check, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }
}
