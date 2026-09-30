import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aevum/core/constants/app_colors.dart';
import 'package:aevum/core/services/haptic_service.dart';
import 'package:aevum/core/widgets/forest_background.dart';
import 'package:aevum/core/theme/app_typography.dart';
import 'package:aevum/core/utils/time_utils.dart';
import 'package:aevum/core/widgets/fade_slide_in.dart';
import 'package:aevum/core/widgets/glass_icon_button.dart';
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

    final segments = [
      for (final task in scheduledToday)
        DailyRingSegment(
          color: task.color,
          done: todaySessions.any((s) => s.taskId == task.id),
        ),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: ForestBackground(
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: FadeSlideIn(child: _HomeHeader(now: now)),
                  ),
                ),

                SliverToBoxAdapter(
                  child: FadeSlideIn(
                    index: 1,
                    child: DailyProgressHeader(
                      totalFocusedMinutes: totalFocusedMinutes,
                      completedTasksCount: completedTasksCount,
                      totalTasksCount: scheduledToday.length,
                      segments: segments,
                      onOpenStats: () => _openStats(context),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: FadeSlideIn(
                    index: 2,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 30, 22, 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            'Seus hábitos',
                            style: AppTypography.serif(
                              size: 22,
                              weight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${tasks.length} ${tasks.length == 1 ? 'ativo' : 'ativos'}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                if (tasks.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: FadeSlideIn(index: 3, child: _EmptyHabits()),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final task = tasks[index];
                      final isDone = todaySessions.any(
                        (s) => s.taskId == task.id,
                      );

                      // Isola o raster para o scroll não repintar cards parados.
                      return FadeSlideIn(
                        key: ValueKey(task.id),
                        index: index + 3,
                        child: RepaintBoundary(
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
                            onEdit: () =>
                                _openCreateTaskSheet(context, ref, task),
                            onDelete: () => _deleteWithUndo(context, ref, task),
                          ),
                        ),
                      );
                    }, childCount: tasks.length),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 140)),
              ],
            ),

            // Névoa no rodapé: a lista se dissolve sob o botão de criar.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 150,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.forestBlack.withValues(alpha: 0),
                        AppColors.forestBlack.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 2, bottom: 6),
        child: GlassCreateTaskButton(
          onPressed: () => _openCreateTaskSheet(context, ref),
        ),
      ),
    );
  }

  void _openStats(BuildContext context) {
    HapticService.lightImpact();
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const StatsScreen()));
  }
}

/// Topo da home: marca, atalhos e uma saudação conforme a hora do dia.
class _HomeHeader extends StatelessWidget {
  final DateTime now;

  const _HomeHeader({required this.now});

  String get _greeting {
    final hour = now.hour;
    if (hour >= 5 && hour < 12) return 'Bom dia';
    if (hour >= 12 && hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/app/aevum-mark.png',
                  width: 30,
                  height: 30,
                  cacheWidth: 90,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Aevum',
                style: AppTypography.serif(size: 20, weight: FontWeight.w500),
              ),
              const Spacer(),
              GlassIconButton(
                icon: Icons.insights_rounded,
                tooltip: 'Estatísticas',
                color: AppColors.sage,
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const StatsScreen())),
              ),
              const SizedBox(width: 8),
              GlassIconButton(
                icon: Icons.info_outline_rounded,
                tooltip: 'Sobre o Aevum',
                color: AppColors.sage,
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const AboutScreen())),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            TimeUtils.formatHeaderDate(now).toUpperCase(),
            style: AppTypography.eyebrow,
          ),
          const SizedBox(height: 6),
          Text(
            _greeting,
            style: AppTypography.serif(
              size: 40,
              weight: FontWeight.w400,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Evolua no seu tempo.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHabits extends StatelessWidget {
  const _EmptyHabits();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 12, 40, 150),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.sage.withValues(alpha: 0.18),
                  AppColors.sage.withValues(alpha: 0.02),
                ],
              ),
              border: Border.all(color: AppColors.sage.withValues(alpha: 0.2)),
            ),
            child: const Icon(
              Icons.park_outlined,
              size: 38,
              color: AppColors.sage,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Plante o primeiro hábito',
            textAlign: TextAlign.center,
            style: AppTypography.serif(size: 22, weight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nenhum hábito cadastrado ainda. Comece pequeno, no seu ritmo.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
