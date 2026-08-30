import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aevum/core/constants/app_colors.dart';
import 'package:aevum/core/providers/app_state_provider.dart';
import 'package:aevum/core/widgets/forest_background.dart';
import 'package:aevum/core/widgets/glass_container.dart';
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
                            duration: const Duration(milliseconds: 220),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: selected ? 28 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.sage
                                  : AppColors.textFaint,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
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
                avatar: Icon(mode.icon, size: 18, color: AppColors.sage),
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
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: GlassContainer(
          strong: true,
          borderRadius: 32,
          accentColor: AppColors.sage,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 38),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  label: eyebrow,
                  child: brandMark
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.asset(
                            'assets/app/aevum-mark.png',
                            width: 80,
                            height: 80,
                          ),
                        )
                      : Icon(icon, size: 72, color: AppColors.sage),
                ),
                const SizedBox(height: 26),
                Text(
                  eyebrow,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    letterSpacing: 2.6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 18),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 16,
                    height: 1.55,
                  ),
                ),
                if (child != null) ...[const SizedBox(height: 24), child!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
