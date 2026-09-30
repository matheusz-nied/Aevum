import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:aevum/core/config/app_performance_policy.dart';
import 'package:aevum/core/constants/app_colors.dart';

/// Fundo procedural de uma floresta ao amanhecer, encoberta por névoa.
///
/// Nenhuma imagem é usada. A cena (céu, camadas de pinheiros em perspectiva
/// atmosférica e vinheta) é pintada uma vez e fica em cache; por cima, uma
/// camada leve anima raios de luz, névoa à deriva e alguns vaga-lumes.
class ForestBackground extends StatefulWidget {
  final Widget child;

  const ForestBackground({super.key, required this.child});

  @override
  State<ForestBackground> createState() => _ForestBackgroundState();
}

class _ForestBackgroundState extends State<ForestBackground>
    with SingleTickerProviderStateMixin {
  AnimationController? _atmosphereController;

  @override
  void initState() {
    super.initState();
    if (AppPerformancePolicy.animateForestAtmosphere) {
      _atmosphereController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 36),
      )..repeat();
    }
  }

  @override
  void dispose() {
    _atmosphereController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _atmosphereController;
    final atmosphere = controller == null
        ? const CustomPaint(painter: _AtmospherePainter(time: 0.18))
        : AnimatedBuilder(
            animation: controller,
            builder: (context, _) => CustomPaint(
              painter: _AtmospherePainter(time: controller.value),
            ),
          );

    return ColoredBox(
      color: AppColors.forestBlack,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const RepaintBoundary(
            child: CustomPaint(isComplex: true, painter: _ForestScenePainter()),
          ),
          IgnorePointer(child: RepaintBoundary(child: atmosphere)),
          widget.child,
        ],
      ),
    );
  }
}

/// Cena estática: céu, luz do amanhecer, três planos de pinheiros e vinheta.
class _ForestScenePainter extends CustomPainter {
  const _ForestScenePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Céu: claro e enevoado no alto, quase preto no chão da mata.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.canopySky,
            Color(0xFF142219),
            AppColors.forestDeep,
            AppColors.forestBlack,
          ],
          stops: [0, 0.36, 0.72, 1],
        ).createShader(rect),
    );

    // Luz do amanhecer atravessando a névoa, no alto e um pouco à esquerda.
    final dawnCenter = Offset(size.width * 0.32, -size.height * 0.04);
    canvas.drawRect(
      rect,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                AppColors.dawn.withValues(alpha: 0.10),
                AppColors.fogSilver.withValues(alpha: 0.07),
                Colors.transparent,
              ],
              stops: const [0, 0.42, 1],
            ).createShader(
              Rect.fromCircle(
                center: dawnCenter,
                radius: size.longestSide * 0.66,
              ),
            ),
    );

    // Plano distante: pinheiros pequenos, quase dissolvidos na névoa.
    _paintRidge(
      canvas,
      size,
      baseline: size.height * 0.66,
      heightFactor: 0.15,
      spacing: 0.085,
      color: AppColors.fogSilver.withValues(alpha: 0.045),
      seed: 3,
    );
    _paintFogBand(canvas, size, top: 0.56, bottom: 0.76, alpha: 0.10);

    // Plano médio.
    _paintRidge(
      canvas,
      size,
      baseline: size.height * 0.82,
      heightFactor: 0.22,
      spacing: 0.13,
      color: const Color(0xFF0F1D16).withValues(alpha: 0.75),
      seed: 11,
    );
    _paintFogBand(canvas, size, top: 0.74, bottom: 0.90, alpha: 0.06);

    // Plano próximo: silhuetas escuras no chão da mata.
    _paintRidge(
      canvas,
      size,
      baseline: size.height * 1.02,
      heightFactor: 0.30,
      spacing: 0.21,
      color: AppColors.forestBlack.withValues(alpha: 0.72),
      seed: 23,
    );

    // Vinheta suave para concentrar o olhar no conteúdo.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.2),
          radius: 1.05,
          colors: [
            Colors.transparent,
            AppColors.forestBlack.withValues(alpha: 0.22),
            AppColors.forestBlack.withValues(alpha: 0.62),
          ],
          stops: const [0.45, 0.78, 1],
        ).createShader(rect),
    );
  }

  void _paintFogBand(
    Canvas canvas,
    Size size, {
    required double top,
    required double bottom,
    required double alpha,
  }) {
    final band = Rect.fromLTRB(
      0,
      size.height * top,
      size.width,
      size.height * bottom,
    );
    canvas.drawRect(
      band,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppColors.fogGlow.withValues(alpha: alpha),
            Colors.transparent,
          ],
        ).createShader(band),
    );
  }

  void _paintRidge(
    Canvas canvas,
    Size size, {
    required double baseline,
    required double heightFactor,
    required double spacing,
    required Color color,
    required int seed,
  }) {
    final paint = Paint()..color = color;
    final random = math.Random(seed);
    final step = size.width * spacing;
    for (var x = -step; x < size.width + step; x += step) {
      final jitterX = (random.nextDouble() - 0.5) * step * 0.6;
      final variation = 0.7 + random.nextDouble() * 0.5;
      _drawPine(
        canvas,
        Offset(x + jitterX, baseline + random.nextDouble() * 12),
        size.height * heightFactor * variation,
        paint,
      );
    }
  }

  void _drawPine(Canvas canvas, Offset base, double height, Paint paint) {
    final trunkWidth = math.max(1.0, height * 0.02);
    canvas.drawRect(
      Rect.fromLTWH(
        base.dx - trunkWidth / 2,
        base.dy - height * 0.3,
        trunkWidth,
        height * 0.3,
      ),
      paint,
    );

    // Camadas de galhos com a base levemente côncava, como pinheiros reais.
    const tiers = 6;
    for (var tier = 0; tier < tiers; tier++) {
      final t = tier / (tiers - 1);
      final tierTop = base.dy - height + height * t * 0.62;
      final tierHeight = height * (0.2 + t * 0.1);
      final halfWidth = height * (0.06 + t * 0.15);
      final path = Path()
        ..moveTo(base.dx, tierTop)
        ..quadraticBezierTo(
          base.dx - halfWidth * 0.35,
          tierTop + tierHeight * 0.55,
          base.dx - halfWidth,
          tierTop + tierHeight,
        )
        ..quadraticBezierTo(
          base.dx,
          tierTop + tierHeight * 0.82,
          base.dx + halfWidth,
          tierTop + tierHeight,
        )
        ..quadraticBezierTo(
          base.dx + halfWidth * 0.35,
          tierTop + tierHeight * 0.55,
          base.dx,
          tierTop,
        )
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ForestScenePainter oldDelegate) => false;
}

/// Camada viva: raios de luz que respiram, névoa que passa e vaga-lumes.
///
/// [time] percorre 0..1 em loop; todas as oscilações usam múltiplos inteiros
/// de 2π para que o fim do ciclo emende no começo sem salto.
class _AtmospherePainter extends CustomPainter {
  final double time;

  const _AtmospherePainter({required this.time});

  static const _fireflyCount = 11;

  @override
  void paint(Canvas canvas, Size size) {
    final phase = time * 2 * math.pi;
    _paintLightRays(canvas, size, phase);
    _paintDriftingMist(canvas, size, phase);
    _paintFireflies(canvas, size, phase);
  }

  void _paintLightRays(Canvas canvas, Size size, double phase) {
    final origin = Offset(size.width * 0.18, -size.height * 0.08);
    const rays = [
      (angle: 0.50, width: 0.10, offset: 0.0),
      (angle: 0.66, width: 0.06, offset: 2.1),
      (angle: 0.82, width: 0.12, offset: 4.2),
      (angle: 1.00, width: 0.05, offset: 1.3),
    ];
    final length = size.longestSide * 1.1;

    for (final ray in rays) {
      final breath = 0.55 + 0.45 * math.sin(phase + ray.offset);
      final a1 = ray.angle - ray.width / 2;
      final a2 = ray.angle + ray.width / 2;
      final path = Path()
        ..moveTo(origin.dx, origin.dy)
        ..lineTo(
          origin.dx + math.cos(a1) * length,
          origin.dy + math.sin(a1) * length,
        )
        ..lineTo(
          origin.dx + math.cos(a2) * length,
          origin.dy + math.sin(a2) * length,
        )
        ..close();
      final end = Offset(
        origin.dx + math.cos(ray.angle) * length * 0.8,
        origin.dy + math.sin(ray.angle) * length * 0.8,
      );
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            colors: [
              AppColors.dawn.withValues(alpha: 0.055 * breath),
              AppColors.fogSilver.withValues(alpha: 0.02 * breath),
              Colors.transparent,
            ],
            stops: const [0, 0.45, 1],
          ).createShader(Rect.fromPoints(origin, end)),
      );
    }
  }

  void _paintDriftingMist(Canvas canvas, Size size, double phase) {
    void mist(double baseX, double y, double radius, double shift, double a) {
      final center = Offset(
        size.width * (baseX + shift * math.sin(phase)),
        size.height * y,
      );
      final rect = Rect.fromCenter(
        center: center,
        width: size.width * radius * 2.2,
        height: size.width * radius * 0.7,
      );
      canvas.drawOval(
        rect,
        Paint()
          ..shader = RadialGradient(
            colors: [
              AppColors.fogSilver.withValues(alpha: a),
              Colors.transparent,
            ],
          ).createShader(rect),
      );
    }

    mist(0.30, 0.62, 0.55, 0.10, 0.05);
    mist(0.75, 0.80, 0.60, -0.08, 0.045);
  }

  void _paintFireflies(Canvas canvas, Size size, double phase) {
    final random = math.Random(7);
    for (var i = 0; i < _fireflyCount; i++) {
      final baseX = random.nextDouble();
      final baseY = 0.45 + random.nextDouble() * 0.5;
      final orbit = 10 + random.nextDouble() * 22;
      final speed = 1 + random.nextInt(2);
      final offset = random.nextDouble() * 2 * math.pi;

      final center = Offset(
        size.width * baseX + math.sin(phase * speed + offset) * orbit,
        size.height * baseY + math.cos(phase * speed + offset * 1.3) * orbit,
      );
      // Cada vaga-lume acende e apaga devagar, fora de sincronia.
      final glow = math.pow(
        0.5 + 0.5 * math.sin(phase * (speed + 1) + offset * 2),
        2.2,
      );
      if (glow < 0.04) continue;

      final color = i.isEven ? AppColors.dawn : AppColors.softGlowEmerald;
      final radius = 9.0 + random.nextDouble() * 5;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: 0.30 * glow),
              color.withValues(alpha: 0.06 * glow),
              Colors.transparent,
            ],
            stops: const [0, 0.25, 1],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
      canvas.drawCircle(
        center,
        1.3,
        Paint()..color = color.withValues(alpha: 0.85 * glow),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AtmospherePainter oldDelegate) =>
      oldDelegate.time != time;
}
