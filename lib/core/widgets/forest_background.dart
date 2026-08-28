import 'package:flutter/material.dart';
import 'package:timing/core/constants/app_colors.dart';

/// Fundo "Floresta Nebulosa" em gradiente puro.
/// Renderiza gradientes verde-escuro com luzes de névoa que se movem
/// lentamente, criando profundidade e calma. Leve para todas as frames.
class ForestBackground extends StatefulWidget {
  final Widget child;

  const ForestBackground({super.key, required this.child});

  @override
  State<ForestBackground> createState() => _ForestBackgroundState();
}

class _ForestBackgroundState extends State<ForestBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _fogController;

  @override
  void initState() {
    super.initState();
    _fogController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _fogController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.forestMid,
            AppColors.forestDeep,
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Névoa suave se movendo (com AnimatedBuilder)
          AnimatedBuilder(
            animation: _fogController,
            builder: (context, child) {
              final progress = _fogController.value;
              return CustomPaint(
                painter: _FogPainter(progress: progress),
              );
            },
          ),
          widget.child,
        ],
      ),
    );
  }
}

/// Pintor de névoa: alguns "glow" radiais suaves que se deslocam lentamente.
class _FogPainter extends CustomPainter {
  final double progress;

  _FogPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Glow superior (luz de névoa no topo)
    final glow1 = Offset(
      size.width * 0.25 + (size.width * 0.35 * progress),
      size.height * 0.18,
    );
    final paint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.fogGlow.withValues(alpha: 0.35),
          AppColors.fogGlow.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(center: glow1, radius: size.width * 0.45),
      );
    canvas.drawRect(Offset.zero & size, paint1);

    // Glow inferior direito (profundidade)
    final glow2 = Offset(
      size.width * (0.85 - (0.25 * progress)),
      size.height * 0.62,
    );
    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.fogGlow2.withValues(alpha: 0.30),
          AppColors.fogGlow2.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(center: glow2, radius: size.width * 0.35),
      );
    canvas.drawRect(Offset.zero & size, paint2);

    // Glow inferior esquerdo (auxiliar)
    final glow3 = Offset(
      size.width * (0.15 + (0.20 * progress)),
      size.height * 0.85,
    );
    final paint3 = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.fogGlow2.withValues(alpha: 0.22),
          AppColors.fogGlow2.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(center: glow3, radius: size.width * 0.28),
      );
    canvas.drawRect(Offset.zero & size, paint3);
  }

  @override
  bool shouldRepaint(covariant _FogPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
