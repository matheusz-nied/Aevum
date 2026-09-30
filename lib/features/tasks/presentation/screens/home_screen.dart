import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aevum/core/constants/app_colors.dart';
import 'package:aevum/core/services/haptic_service.dart';
import 'package:aevum/core/widgets/forest_background.dart';
import 'package:aevum/core/widgets/glass_container.dart';
import 'package:aevum/features/about/presentation/about_screen.dart';
import 'package:aevum/features/stats/presentation/screens/stats_screen.dart';
import 'package:aevum/features/tasks/domain/task_model.dart';
import 'package:aevum/features/tasks/presentation/widgets/create_task_sheet.dart';
import 'package:aevum/features/tasks/presentation/widgets/daily_progress_header.dart';
import 'package:aevum/features/tasks/presentation/widgets/glass_create_task_button.dart';
import 'package:aevum/features/tasks/presentation/widgets/task_card.dart';
import 'package:aevum/features/tasks/providers/task_providers.dart';
import 'package:aevum/features/timer/presentation/screens/active_timer_screen.dart';
import 'package:aevum/features/timer/providers/timer_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    this.openCreateOnStart = false,
    this.onInitialCreateOpened,
  });

  final bool openCreateOnStart;
  final VoidCallback? onInitialCreateOpened;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _handledInitialCreate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _offerSavedSession());
    if (widget.openCreateOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _handledInitialCreate) return;
        _handledInitialCreate = true;
        widget.onInitialCreateOpened?.call();
        _openCreateTaskSheet(context, ref);
      });
    }
  }

  /// Se o sistema encerrou o app no meio de uma sessão, oferece retomá-la.
  Future<void> _offerSavedSession() async {
    final store = ref.read(timerSessionStoreProvider);
    final snapshot = store?.load();
    if (store == null || snapshot == null || !mounted) return;

    final task = ref
        .read(taskListProvider)
        .where((t) => t.id == snapshot.taskId)
        .firstOrNull;
    if (task == null || snapshot.elapsedMs < 1000) {
      await store.clear();
      return;
    }

    final minutes = Duration(milliseconds: snapshot.elapsedMs).inMinutes;
    final resume = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Retomar sessão?'),
        content: Text(
          'O app foi fechado durante "${task.title}", com $minutes min já feitos. Quer continuar de onde parou?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Descartar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Retomar'),
          ),
        ],
      ),
    );
    if (!mounted) return;

    if (resume == true) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ActiveTimerScreen(task: task, resumeFrom: snapshot),
        ),
      );
    } else {
      await store.clear();
    }
  }

  void _openCreateTaskSheet(
    BuildContext context,
    WidgetRef ref, [
    TaskModel? existing,
  ]) {
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

  void _deleteWithUndo(BuildContext context, WidgetRef ref, TaskModel task) {
    HapticService.mediumImpact();
    final notifier = ref.read(taskListProvider.notifier);
    notifier.deleteTask(task.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('"${task.title}" foi excluído.'),
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () => notifier.addTask(task),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskListProvider);
    final sessions = ref.watch(sessionListProvider);
    final totalFocusedMinutes = ref.watch(todayCompletedMinutesProvider);

    final now = DateTime.now();
    final todaySessions = sessions.where((s) {
      return s.completedAt.year == now.year &&
          s.completedAt.month == now.month &&
          s.completedAt.day == now.day;
    }).toList();

    final scheduledToday = tasks.where((t) => t.isScheduledOn(now)).toList();
    final completedTasksCount = scheduledToday.where((t) {
      return todaySessions.any((s) => s.taskId == t.id);
    }).length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: ForestBackground(
        child: CustomScrollView(
          slivers: [
            // AppBar em vidro
            SliverToBoxAdapter(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GlassContainer(
                            isCircle: true,
                            accentColor: AppColors.sage,
                            padding: const EdgeInsets.all(10),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/app/aevum-mark.png',
                                width: 22,
                                height: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 11),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Aevum',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 21,
                                  letterSpacing: -0.5,
                                  color: AppColors.textWhite,
                                ),
                              ),
                              Text(
                                'EVOLUA NO SEU TEMPO',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                  letterSpacing: 1.35,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          GlassContainer(
                            isCircle: true,
                            accentColor: AppColors.sage,
                            child: IconButton(
                              onPressed: () {
                                HapticService.lightImpact();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const StatsScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.insights_rounded,
                                size: 20,
                                color: AppColors.sage,
                              ),
                              tooltip: 'Estatísticas',
                            ),
                          ),
                          const SizedBox(width: 8),
                          GlassContainer(
                            isCircle: true,
                            accentColor: AppColors.sage,
                            child: IconButton(
                              onPressed: () {
                                HapticService.lightImpact();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const AboutScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.info_outline_rounded,
                                size: 20,
                                color: AppColors.sage,
                              ),
                              tooltip: 'Sobre o Aevum',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Daily Progress Header
            SliverToBoxAdapter(
              child: DailyProgressHeader(
                totalFocusedMinutes: totalFocusedMinutes,
                completedTasksCount: completedTasksCount,
                totalTasksCount: scheduledToday.length,
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
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 9),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Seus hábitos',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.25,
                        color: AppColors.textWhite,
                      ),
                    ),
                    Text(
                      '${tasks.length} ${tasks.length == 1 ? 'ativo' : 'ativos'}',
                      style: const TextStyle(
                        fontSize: 11,
                        letterSpacing: 0.4,
                        color: AppColors.textMuted,
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
                      const Icon(
                        Icons.park_rounded,
                        size: 64,
                        color: AppColors.textFaint,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum hábito cadastrado',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite.withValues(alpha: 0.75),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Crie seu primeiro hábito e comece no seu ritmo.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final task = tasks[index];
                  final isDone = todaySessions.any((s) => s.taskId == task.id);

                  // Cada card tem 2 CustomPaints + 2 BoxShadows: isola o
                  // raster para o scroll não repintar cards parados.
                  return RepaintBoundary(
                    child: TaskCard(
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
                      onDelete: () => _deleteWithUndo(context, ref, task),
                    ),
                  );
                }, childCount: tasks.length),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 2, bottom: 4),
        child: GlassCreateTaskButton(
          onPressed: () => _openCreateTaskSheet(context, ref),
        ),
      ),
    );
  }
}
