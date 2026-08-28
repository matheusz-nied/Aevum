import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:timing/core/constants/app_colors.dart';
import 'package:timing/features/tasks/domain/task_model.dart';
import 'package:timing/features/timer/domain/timer_state.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = widget.task.color;

    return AnimatedBuilder(
      animation: _ambientController,
      builder: (context, child) {
        final glowIntensity = 0.2 + (_ambientController.value * 0.25);

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Zen Header (Ref 3)
            Column(
              children: [
                Icon(
                  Icons.spa_rounded,
                  color: accentColor,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  'Modo Sem Pressa',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.task.title,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            // Glassmorphism Zen Capsule (Ref 3)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    width: 260,
                    height: 380,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF161A20).withValues(alpha: 0.75)
                          : Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.black.withValues(alpha: 0.08),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Soft glowing orb in capsule window
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                accentColor.withValues(alpha: 0.8),
                                accentColor.withValues(alpha: 0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              widget.task.iconData,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        // Peaceful status message (ZERO digits)
                        Column(
                          children: [
                            Text(
                              widget.state.isRunning
                                  ? 'Foco em andamento...'
                                  : widget.state.isPaused
                                      ? 'Em pausa suave'
                                      : 'Pronto para iniciar',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Apenas concentre-se na sua atividade. Avisaremos com som sutil ao terminar.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color:
                                    isDark ? AppColors.textMuted : Colors.black54,
                              ),
                            ),
                          ],
                        ),

                        // Play / Pause in capsule
                        IconButton.filled(
                          onPressed: widget.onTogglePlayPause,
                          style: IconButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(18),
                          ),
                          icon: Icon(
                            widget.state.isRunning
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Subtle Reset
            TextButton.icon(
              onPressed: widget.onReset,
              icon: Icon(Icons.refresh_rounded,
                  size: 18,
                  color: isDark ? AppColors.textMuted : Colors.black45),
              label: Text(
                'Recomeçar sessão',
                style: TextStyle(
                  color: isDark ? AppColors.textMuted : Colors.black45,
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
