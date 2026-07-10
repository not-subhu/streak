import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme.dart';

class DotGrid extends StatelessWidget {
  final Habit habit;
  final int days;

  const DotGrid({super.key, required this.habit, this.days = 182});

  String _key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayStr = _key(now);
    final color = Color(habit.color);

    // Build list of day keys: oldest first, newest last
    final dayKeys = List.generate(days, (i) {
      final d = now.subtract(Duration(days: days - 1 - i));
      return _key(d);
    });

    // 26 columns × 7 rows
    return LayoutBuilder(builder: (context, constraints) {
      const cols = 26;
      const rows = 7;
      final gap = 2.5;
      final dotSize = (constraints.maxWidth - gap * (cols - 1)) / cols;

      return SizedBox(
        height: dotSize * rows + gap * (rows - 1),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: gap,
            crossAxisSpacing: gap,
          ),
          itemCount: cols * rows,
          itemBuilder: (context, index) {
            // index 0 = top-left (oldest), fill column by column
            final col = index % cols;
            final row = index ~/ cols;
            final dayIndex = col * rows + row;
            if (dayIndex >= dayKeys.length) {
              return const SizedBox();
            }
            final k = dayKeys[dayIndex];
            final done = habit.completions[k] == true;
            final isToday = k == todayStr;

            return Container(
              decoration: BoxDecoration(
                color: done ? color : AppTheme.muted2,
                borderRadius: BorderRadius.circular(2),
                border: isToday
                    ? Border.all(color: Colors.white.withOpacity(0.35), width: 1.2)
                    : null,
              ),
            );
          },
        ),
      );
    });
  }
}
