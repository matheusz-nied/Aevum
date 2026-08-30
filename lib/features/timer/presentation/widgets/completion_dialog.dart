import 'package:aevum/core/constants/app_colors.dart';
import 'package:aevum/core/quotes/inspiration_quotes.dart';
import 'package:aevum/core/services/haptic_service.dart';
import 'package:aevum/core/widgets/glass_container.dart';
import 'package:aevum/features/tasks/domain/session_record.dart';
import 'package:aevum/features/tasks/domain/task_model.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CompletionDialog extends StatefulWidget {
  final TaskModel task;
  final int durationSeconds;
  final ValueChanged<SessionRecord> onConfirm;

  const CompletionDialog({
    super.key,
    required this.task,
    required this.durationSeconds,
    required this.onConfirm,
  });

  @override
  State<CompletionDialog> createState() => _CompletionDialogState();
}

class _CompletionDialogState extends State<CompletionDialog>
    with SingleTickerProviderStateMixin {
  late final String _praise;
  late final AnimationController _entranceController;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _praise = InspirationQuotes.getRandomCompletionPraise();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _fade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0, 0.72, curve: Curves.easeOut),
    );
    _scale = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
    );
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  void _confirm() {
    HapticService.mediumImpact();
    final session = SessionRecord(
      id: const Uuid().v4(),
      taskId: widget.task.id,
      completedAt: DateTime.now(),
      durationSeconds: widget.durationSeconds,
      completedGoal: true,
    );
    widget.onConfirm(session);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.task.color;
    final minutes = widget.durationSeconds ~/ 60;
    final durationLabel = minutes == 1 ? '1 minuto' : '$minutes minutos';

    return Dialog(
      elevation: 0,
      shadowColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: FadeTransition(
        opacity: _fade,
        child: ScaleTransition(
          scale: _scale,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: GlassContainer(
              borderRadius: 32,
              blur: 28,
              strong: true,
              accentColor: accentColor,
              color: AppColors.forestSurface.withValues(alpha: 0.34),
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CelebrationOrb(accentColor: accentColor),
                  const SizedBox(height: 22),
                  const Text(
                    'Hábito concluído',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textWhite,
                      letterSpacing: -0.65,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.task.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _DurationPill(
                    durationLabel: durationLabel,
                    accentColor: accentColor,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '“$_praise”',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 26),
                  _GlassConfirmButton(
                    accentColor: accentColor,
                    onPressed: _confirm,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CelebrationOrb extends StatelessWidget {
  final Color accentColor;

  const _CelebrationOrb({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      isCircle: true,
      blur: 18,
      accentColor: accentColor,
      color: accentColor.withValues(alpha: 0.13),
      child: SizedBox.square(
        dimension: 82,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accentColor.withValues(alpha: 0.25),
                    accentColor.withValues(alpha: 0.04),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.28),
                    blurRadius: 22,
                    spreadRadius: -4,
                  ),
                ],
              ),
            ),
            Icon(Icons.check_rounded, size: 38, color: accentColor),
          ],
        ),
      ),
    );
  }
}

class _DurationPill extends StatelessWidget {
  final String durationLabel;
  final Color accentColor;

  const _DurationPill({required this.durationLabel, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.10),
            accentColor.withValues(alpha: 0.09),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 15, color: accentColor),
          const SizedBox(width: 7),
          Text(
            '$durationLabel de presença',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textWhite,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassConfirmButton extends StatelessWidget {
  final Color accentColor;
  final VoidCallback onPressed;

  const _GlassConfirmButton({
    required this.accentColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final fill = Color.alphaBlend(
      Colors.white.withValues(alpha: 0.25),
      accentColor,
    );

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [fill, accentColor],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.24),
              blurRadius: 22,
              spreadRadius: -7,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.13),
              blurRadius: 3,
              offset: const Offset(-1, -1),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(18),
            child: const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Salvar e finalizar',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.forestDeep,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: AppColors.forestDeep,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
