import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habits_provider.dart';
import '../theme.dart';
import '../widgets/dot_grid.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Consumer<HabitsProvider>(
          builder: (context, provider, _) {
            if (!provider.loaded) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
            }
            if (provider.habits.isEmpty) {
              return const Center(
                child: Text(
                  'Add habits to see stats',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                ),
              );
            }
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: const Text(
                      'Statistics',
                      style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary, letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),

                // Summary row
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    child: _SummaryRow(provider: provider),
                  ),
                ),

                // Per-habit stats
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _HabitStatCard(habit: provider.habits[i]),
                      ),
                      childCount: provider.habits.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final HabitsProvider provider;
  const _SummaryRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final total = provider.habits.fold(0, (s, h) => s + h.totalCompletions);
    final avgRate = provider.habits.isEmpty
        ? 0.0
        : provider.habits.map((h) => h.completionRate(30)).reduce((a, b) => a + b) /
            provider.habits.length;

    return Row(
      children: [
        _BigStat(value: '$total', label: 'Total\nchecks'),
        const SizedBox(width: 8),
        _BigStat(value: '${(avgRate * 100).round()}%', label: '30-day\naverage'),
        const SizedBox(width: 8),
        _BigStat(
          value: '${provider.bestCurrentStreak}',
          label: 'Best\nstreak',
        ),
      ],
    );
  }
}

class _BigStat extends StatelessWidget {
  final String value;
  final String label;
  const _BigStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 26, fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary, fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 9, color: AppTheme.textMuted, letterSpacing: 0.5, height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitStatCard extends StatelessWidget {
  final Habit habit;
  const _HabitStatCard({required this.habit});

  @override
  Widget build(BuildContext context) {
    final color = Color(habit.color);
    final rate7 = habit.completionRate(7);
    final rate30 = habit.completionRate(30);
    final longest = habit.longestStreak;
    final current = habit.currentStreak;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
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
              Expanded(
                child: Text(
                  habit.name,
                  style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Text(
                '${habit.totalCompletions} total',
                style: const TextStyle(
                  fontSize: 11, color: AppTheme.textMuted, fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Mini stats row
          Row(
            children: [
              _MiniStat(label: 'Current', value: '$current days', color: color),
              const SizedBox(width: 8),
              _MiniStat(label: 'Longest', value: '$longest days', color: color),
              const SizedBox(width: 8),
              _MiniStat(label: '7-day', value: '${(rate7 * 100).round()}%', color: color),
              const SizedBox(width: 8),
              _MiniStat(label: '30-day', value: '${(rate30 * 100).round()}%', color: color),
            ],
          ),
          const SizedBox(height: 14),

          // Compact dot grid (last 12 weeks)
          DotGrid(habit: habit, days: 84),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: color, fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 8, color: AppTheme.textMuted, letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
