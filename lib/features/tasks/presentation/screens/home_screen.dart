import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timing/core/constants/app_colors.dart';
import 'package:timing/core/services/haptic_service.dart';
import 'package:timing/features/stats/presentation/screens/stats_screen.dart';
import 'package:timing/features/tasks/domain/task_model.dart';
import 'package:timing/features/tasks/presentation/widgets/create_task_sheet.dart';
import 'package:timing/features/tasks/presentation/widgets/daily_progress_header.dart';
import 'package:timing/features/tasks/presentation/widgets/task_card.dart';
import 'package:timing/features/tasks/providers/task_providers.dart';
import 'package:timing/features/timer/presentation/screens/active_timer_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openCreateTaskSheet(BuildContext context, WidgetRef ref,
      [TaskModel? existing]) {
    HapticService.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreateTaskSheet(
        existingTask: existing,
        onSave: (task) {
          if (existing != null) {
            ref.read(taskListProvider.notifier).updateTask(task);
          } else {
            ref.read(taskListProvider.notifier).addTask(task);
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, TaskModel task) {
    HapticService.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir hábito?'),
        content: Text(
            'Deseja realmente remover "${task.title}"? O histórico de sessões será mantido.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(taskListProvider.notifier).deleteTask(task.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Excluir',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskListProvider);
    final sessions = ref.watch(sessionListProvider);
    final totalFocusedMinutes = ref.watch(todayCompletedMinutesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final now = DateTime.now();
    final todaySessions = sessions.where((s) {
      return s.completedAt.year == now.year &&
          s.completedAt.month == now.month &&
          s.completedAt.day == now.day;
    }).toList();

    final completedTasksCount = tasks.where((t) {
      return todaySessions.any((s) => s.taskId == t.id);
    }).length;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.warmAmber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.hourglass_top_rounded,
                color: AppColors.warmAmber,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Timing',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              HapticService.lightImpact();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StatsScreen()),
              );
            },
            icon: const Icon(Icons.insights_rounded, size: 24),
            tooltip: 'Estatísticas',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Daily Progress Header Card (Ref 2)
          SliverToBoxAdapter(
            child: DailyProgressHeader(
              totalFocusedMinutes: totalFocusedMinutes,
              completedTasksCount: completedTasksCount,
              totalTasksCount: tasks.length,
              onOpenStats: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const StatsScreen()),
                );
              },
            ),
          ),

          // Section Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Seus Hábitos & Timers',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  Text(
                    '${tasks.length} ativos',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textMuted : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tasks List
          if (tasks.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 64,
                      color: isDark ? Colors.white24 : Colors.black12,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum hábito cadastrado',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Toque no botão abaixo para criar seu primeiro timer!',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textMuted : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final task = tasks[index];
                  final isDone =
                      todaySessions.any((s) => s.taskId == task.id);

                  return TaskCard(
                    task: task,
                    isCompletedToday: isDone,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ActiveTimerScreen(task: task),
                        ),
                      );
                    },
                    onEdit: () => _openCreateTaskSheet(context, ref, task),
                    onDelete: () => _confirmDelete(context, ref, task),
                  );
                },
                childCount: tasks.length,
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateTaskSheet(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Novo Hábito',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
