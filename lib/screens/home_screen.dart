import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habits_provider.dart';
import '../theme.dart';
import '../widgets/habit_card.dart';
import '../widgets/add_habit_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
            return CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(child: _Header(provider: provider)),

                // Stats panel (collapsible)
                SliverToBoxAdapter(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: provider.statsExpanded
                        ? _StatsPanel(provider: provider)
                        : const SizedBox.shrink(),
                  ),
                ),

                // Habits list
                if (provider.habits.isEmpty)
                  const SliverFillRemaining(child: _EmptyState())
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    sliver: SliverReorderableList(
                      itemCount: provider.habits.length,
                      onReorder: provider.reorderHabits,
                      itemBuilder: (ctx, i) {
                        final h = provider.habits[i];
                        return ReorderableDragStartListener(
                          key: Key(h.id),
                          index: i,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: HabitCard(habit: h),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const AddHabitSheet(),
        ),
        backgroundColor: AppTheme.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        child: const Icon(Icons.add, size: 26),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final HabitsProvider provider;
  const _Header({required this.provider});

  String _todayLabel() {
    final now = DateTime.now();
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[now.weekday % 7]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'streaks.',
                style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary, letterSpacing: -0.5,
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                _todayLabel(),
                style: const TextStyle(
                  fontSize: 11, color: AppTheme.textMuted,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const Spacer(),
          // Collapse stats toggle
          GestureDetector(
            onTap: provider.toggleStatsExpanded,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border),
              ),
              alignment: Alignment.center,
              child: AnimatedRotation(
                turns: provider.statsExpanded ? 0 : 0.5,
                duration: const Duration(milliseconds: 250),
                child: const Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: AppTheme.textMuted, size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsPanel extends StatelessWidget {
  final HabitsProvider provider;
  const _StatsPanel({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          _StatCard(
            value: '${provider.doneToday}/${provider.totalHabits}',
            label: 'Done today',
          ),
          const SizedBox(width: 8),
          _StatCard(
            value: '${provider.bestCurrentStreak}',
            label: 'Best streak',
          ),
          const SizedBox(width: 8),
          _StatCard(
            value: '${provider.totalHabits}',
            label: 'Habits',
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary, fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 9, color: AppTheme.textMuted, letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.border),
            ),
            alignment: Alignment.center,
            child: const Text('◎', style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(height: 16),
          const Text(
            'No habits yet',
            style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap + to add your first one',
            style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}
