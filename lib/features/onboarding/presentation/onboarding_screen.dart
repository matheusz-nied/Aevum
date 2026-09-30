import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aevum/core/constants/app_colors.dart';
import 'package:aevum/core/providers/app_state_provider.dart';
import 'package:aevum/core/widgets/forest_background.dart';
import 'package:aevum/core/theme/app_typography.dart';
import 'package:aevum/features/tasks/domain/timer_visual_mode.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;
  bool _finishing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _advance() async {
    if (_page < 2) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _controller.jumpToPage(_page + 1);
      } else {
        await _controller.nextPage(
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
        );
      }
      return;
    }

    if (_finishing) return;
    setState(() => _finishing = true);
    await ref.read(appStateProvider.notifier).completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ForestBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (value) => setState(() => _page = value),
                  children: const [
                    _PhilosophyPage(),
                    _ModesPage(),
                    _ForegroundPage(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  children: [
                    Semantics(
                      label: 'Etapa ${_page + 1} de 3',
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final selected = index == _page;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 320),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: selected ? 26 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.dawn
                                  : Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _finishing ? null : _advance,
                        child: Text(
                          _page == 2
                              ? 'Criar meu primeiro hábito'
                              : 'Continuar',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhilosophyPage extends StatelessWidget {
  const _PhilosophyPage();

  @override
  Widget build(BuildContext context) {
    return const _PageShell(
      icon: Icons.park_rounded,
      brandMark: true,
      eyebrow: 'AEVUM',
      title: 'Evolua no seu tempo',
      body: 'Cultive hábitos que fazem bem, com constância tranquila e sem transformar cada dia em uma corrida.',
    );
  }
}

class _ModesPage extends StatelessWidget {
  const _ModesPage();

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      icon: Icons.blur_circular_rounded,
      eyebrow: 'SEU RITUAL',
      title: 'Escolha como perceber o tempo',
      body:
          'Cinco experiências visuais acompanham diferentes momentos de foco.',
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: TimerVisualMode.values
            .map(
              (mode) => Chip(
                avatar: Icon(mode.icon, size: 17, color: AppColors.sage),
                label: Text(mode.displayName),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ForegroundPage extends StatelessWidget {
  const _ForegroundPage();

  @override
  Widget build(BuildContext context) {
    return const _PageShell(
      icon: Icons.phone_android_rounded,
      eyebrow: 'PRESENÇA',
      title: 'Um momento por vez',
      body: 'Durante uma sessão, mantenha o Aevum aberto. Se você sair do app, o timer pausa para que nenhum tempo seja contado sem sua presença.',
    );
  }
}

class _PageShell extends StatelessWidget {
  const _PageShell({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.body,
    this.child,
    this.brandMark = false,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final String body;
  final Widget? child;
  final bool brandMark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: eyebrow,
              child: _GlowOrb(
                child: brandMark
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/app/aevum-mark.png',
                          width: 84,
                          height: 84,
                          // Decodifica já no tamanho exibido em vez de 256px.
                          cacheWidth: 252,
                        ),
                      )
                    : Icon(icon, size: 52, color: AppColors.sage),
              ),
            ),
            const SizedBox(height: 36),
            Text(
              eyebrow,
              style: AppTypography.eyebrow.copyWith(
                color: AppColors.dawn,
                letterSpacing: 2.6,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.serif(size: 38, height: 1.1),
            ),
            const SizedBox(height: 18),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 16,
                height: 1.6,
              ),
            ),
            if (child != null) ...[const SizedBox(height: 28), child!],
          ],
        ),
      ),
    );
  }
}

/// Halo de luz suave atrás do ícone de cada etapa.
class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      height: 148,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.sage.withValues(alpha: 0.16),
            AppColors.sage.withValues(alpha: 0.04),
            Colors.transparent,
          ],
          stops: const [0, 0.6, 1],
        ),
      ),
      child: Center(
        child: Container(
          width: 112,
          height: 112,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.03),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
