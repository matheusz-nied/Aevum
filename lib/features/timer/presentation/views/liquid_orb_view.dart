import 'package:flutter/material.dart';
import 'package:timing/core/constants/app_colors.dart';
import 'package:timing/features/tasks/domain/task_model.dart';
import 'package:timing/features/timer/domain/timer_state.dart';
import 'package:timing/features/timer/presentation/widgets/liquid_glass_sphere.dart';

/// A segunda interpretação do vidro líquido preservada do stash.
///
/// Diferente do modo anti-ansiedade, este orbe é mais energético, responde ao
/// arraste e reduz suavemente sua velocidade quando o timer é pausado.
class LiquidOrbView extends StatefulWidget {
  final TaskModel task;
  final TimerState state;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onReset;
  final ValueChanged<int> onAddMinutes;

  const LiquidOrbView({
    super.key,
    required this.task,
    required this.state,
    required this.onTogglePlayPause,
    required this.onReset,
    required this.onAddMinutes,
  });

  @override
  State<LiquidOrbView> createState() => _LiquidOrbViewState();
}

class _LiquidOrbViewState extends State<LiquidOrbView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _textFadeController;

  @override
  void initState() {
    super.initState();
    _textFadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _textFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sphereSize = (constraints.maxHeight * 0.44).clamp(220.0, 310.0);

        return Column(
          children: [
            const SizedBox(height: 6),
            AnimatedBuilder(
              animation: _textFadeController,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.state.isRunning
                            ? const Color(0xFF00E5FF)
                            : AppColors.textMuted.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.state.isRunning
                          ? 'FLUXO ATIVO'
                          : widget.state.isPaused
                          ? 'EM PAUSA'
                          : 'PRONTO PARA INICIAR',
                      style: TextStyle(
                        color: AppColors.textMuted.withValues(
                          alpha: 0.70 + (_textFadeController.value * 0.30),
                        ),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.2,
                      ),
                    ),
                  ],
                );
              },
            ),
            Expanded(
              child: Center(
                child: LiquidGlassSphere(
                  isRunning: widget.state.isRunning,
                  progress: widget.state.progress,
                  accentColor: widget.task.color,
                  size: sphereSize,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MattePlayPauseButton(
                    isRunning: widget.state.isRunning,
                    onTap: widget.onTogglePlayPause,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SubtleActionButton(
                        label: '+1 min',
                        onTap: () => widget.onAddMinutes(1),
                      ),
                      const SizedBox(width: 16),
                      _SubtleActionButton(
                        label: 'Reiniciar',
                        onTap: widget.onReset,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MattePlayPauseButton extends StatefulWidget {
  final bool isRunning;
  final VoidCallback onTap;

  const _MattePlayPauseButton({required this.isRunning, required this.onTap});

  @override
  State<_MattePlayPauseButton> createState() => _MattePlayPauseButtonState();
}

class _MattePlayPauseButtonState extends State<_MattePlayPauseButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final actionLabel = widget.isRunning ? 'Pausar' : 'Continuar';

    return Semantics(
      button: true,
      label: actionLabel,
      child: Tooltip(
        message: actionLabel,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onTap();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.94 : 1,
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF14201A).withValues(alpha: 0.88),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  widget.isRunning
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  size: 24,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SubtleActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SubtleActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.textMuted.withValues(alpha: 0.60),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
