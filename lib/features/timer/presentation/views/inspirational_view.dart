import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:aevum/core/widgets/adaptive_backdrop_filter.dart';
import 'package:aevum/core/constants/app_colors.dart';
import 'package:aevum/core/quotes/inspiration_quotes.dart';
import 'package:aevum/core/utils/time_utils.dart';
import 'package:aevum/core/widgets/glass_container.dart';
import 'package:aevum/features/tasks/domain/task_model.dart';
import 'package:aevum/features/timer/domain/timer_state.dart';

class InspirationalView extends StatefulWidget {
  final TaskModel task;
  final TimerState state;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onReset;
  final Function(int) onAddMinutes;

  const InspirationalView({
    super.key,
    required this.task,
    required this.state,
    required this.onTogglePlayPause,
    required this.onReset,
    required this.onAddMinutes,
  });

  @override
  State<InspirationalView> createState() => _InspirationalViewState();
}

class _InspirationalViewState extends State<InspirationalView> {
  late String _currentQuote;
  Timer? _quoteTimer;

  @override
  void initState() {
    super.initState();
    _currentQuote = InspirationQuotes.getRandomAffirmation(
      taskTitle: widget.task.title,
    );
    _startQuoteCycle();
  }

  void _startQuoteCycle() {
    _quoteTimer?.cancel();
    _quoteTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      if (mounted && widget.state.isRunning) {
        setState(() {
          _currentQuote = InspirationQuotes.getRandomAffirmation(
            taskTitle: widget.task.title,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _quoteTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.task.color;
    final remaining = widget.state.remainingSeconds;
    final displayTime = TimeUtils.formatSeconds(remaining);
    final hasHours = remaining >= 3600;

    return Column(
      children: [
        const SizedBox(height: 8),
        Expanded(
          child: Align(
            alignment: const Alignment(0, -0.28),
            child: SizedBox(
              width: 318,
              height: 318,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(318, 318),
                    painter: _SoftProgressRingPainter(
                      progress: widget.state.progress,
                      accentColor: accentColor,
                      isRunning: widget.state.isRunning,
                    ),
                  ),
                  SizedBox(
                    width: 278,
                    height: 278,
                    child: GlassContainer(
                      isCircle: true,
                      strong: true,
                      blur: 22,
                      accentColor: accentColor,
                      padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 700),
                            transitionBuilder: (child, anim) =>
                                FadeTransition(opacity: anim, child: child),
                            child: Text(
                              _currentQuote,
                              key: ValueKey(_currentQuote),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w400,
                                height: 1.45,
                                fontStyle: FontStyle.italic,
                                color: AppColors.textWhite.withValues(
                                  alpha: 0.72,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            width: 36,
                            height: 1,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(99),
                              gradient: LinearGradient(
                                colors: [
                                  accentColor.withValues(alpha: 0),
                                  accentColor.withValues(alpha: 0.55),
                                  accentColor.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            displayTime,
                            style: TextStyle(
                              fontSize: hasHours ? 34 : 46,
                              fontWeight: FontWeight.w200,
                              height: 1,
                              letterSpacing: hasHours ? 2.5 : 5,
                              color: AppColors.textWhite.withValues(
                                alpha: 0.96,
                              ),
                              shadows: [
                                Shadow(
                                  color: accentColor.withValues(alpha: 0.45),
                                  blurRadius: 22,
                                ),
                                Shadow(
                                  color: accentColor.withValues(alpha: 0.18),
                                  blurRadius: 40,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.state.isRunning
                                ? 'restante'
                                : widget.state.isPaused
                                ? 'em pausa'
                                : 'pronto',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 2.4,
                              color: accentColor.withValues(alpha: 0.78),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SoftIconButton(
                icon: Icons.add,
                onPressed: () => widget.onAddMinutes(1),
              ),
              const SizedBox(width: 22),
              _SoftPlayButton(
                isRunning: widget.state.isRunning,
                accentColor: accentColor,
                onTap: widget.onTogglePlayPause,
              ),
              const SizedBox(width: 22),
              _SoftIconButton(
                icon: Icons.refresh_rounded,
                onPressed: widget.onReset,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SoftPlayButton extends StatelessWidget {
  final bool isRunning;
  final Color accentColor;
  final VoidCallback onTap;

  const _SoftPlayButton({
    required this.isRunning,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: accentColor.withValues(alpha: 0.92),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.32),
              blurRadius: 22,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
          size: 28,
          color: AppColors.forestDeep,
        ),
      ),
    );
  }
}

class _SoftIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _SoftIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: AdaptiveBackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Icon(icon, color: AppColors.textWhite, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}

class _SoftProgressRingPainter extends CustomPainter {
  final double progress;
  final Color accentColor;
  final bool isRunning;

  _SoftProgressRingPainter({
    required this.progress,
    required this.accentColor,
    required this.isRunning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 7;

    final track = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    final arc = Paint()
      ..color = accentColor.withValues(alpha: isRunning ? 0.92 : 0.55)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.4);

    canvas.drawCircle(center, radius, track);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress.clamp(0.0, 1.0),
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _SoftProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.isRunning != isRunning;
  }
}
