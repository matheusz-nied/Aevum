import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:timing/core/constants/app_colors.dart';
import 'package:timing/features/tasks/domain/task_model.dart';
import 'package:timing/features/timer/domain/timer_state.dart';

/// View "Sem Pressa" — cápsula de vidro calmante, a que mais se parece
/// com o design de referência forest.jpg.
class AnxietyFreeView extends StatefulWidget {
  final TaskModel task;
  final TimerState state;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onReset;

  const AnxietyFreeView({
    super.key,
    required this.task,
    required this.state,
    required this.onTogglePlayPause,
    required this.onReset,
  });

  @override
  State<AnxietyFreeView> createState() => _AnxietyFreeViewState();
}

class _AnxietyFreeViewState extends State<AnxietyFreeView>
    with SingleTickerProviderStateMixin {
  late AnimationController _ambientController;

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.task.color;

    return AnimatedBuilder(
      animation: _ambientController,
      builder: (context, child) {
        final glowIntensity = 0.15 + (_ambientController.value * 0.25);

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Header
            Column(
              children: [
                Icon(
                  Icons.eco_rounded,
                  color: AppColors.sage,
                  size: 26,
                ),
                const SizedBox(height: 8),
                Text(
                  'modo calma',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.task.title,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            // Cápsula de vidro → o estilo central da referência
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(48),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    width: 260,
                    height: 380,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.14),
                          Colors.white.withValues(alpha: 0.04),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(48),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.16),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: glowIntensity),
                          blurRadius: 40,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Orbe calmante
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                accentColor.withValues(alpha: 0.85),
                                accentColor.withValues(alpha: 0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              widget.task.iconData,
                              size: 40,
                              color: AppColors.textWhite,
                            ),
                          ),
                        ),

                        // Mensagens
                        Column(
                          children: [
                            Text(
                              widget.state.isRunning
                                  ? 'Foco em andamento'
                                  : widget.state.isPaused
                                      ? 'Pausa suave'
                                      : 'Pronto para iniciar',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textWhite,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Apenas concentre-se. Avisaremos com som suave ao terminar.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),

                        // Play/Pause
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withValues(alpha: 0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: IconButton.filled(
                            onPressed: widget.onTogglePlayPause,
                            style: IconButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: AppColors.forestDeep,
                              padding: const EdgeInsets.all(16),
                            ),
                            icon: Icon(
                              widget.state.isRunning
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: 32,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Reset
            TextButton.icon(
              onPressed: widget.onReset,
              icon: const Icon(
                Icons.refresh_rounded,
                size: 18,
                color: AppColors.textMuted,
              ),
              label: const Text(
                'Recomeçar sessão',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
