import 'package:flutter/material.dart';
import 'package:aevum/core/constants/app_colors.dart';
import 'package:aevum/core/theme/app_typography.dart';
import 'package:aevum/core/widgets/forest_background.dart';
import 'package:aevum/core/widgets/glass_container.dart';
import 'package:aevum/core/widgets/glass_icon_button.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ForestBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 48),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GlassIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  iconSize: 17,
                  tooltip: 'Voltar',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PRIVACIDADE', style: AppTypography.eyebrow),
                    const SizedBox(height: 6),
                    Text(
                      'Privacidade no Aevum',
                      style: AppTypography.serif(size: 34, height: 1.1),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Última atualização: 30 de agosto de 2026',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              GlassContainer(
                strong: true,
                borderRadius: 28,
                accentColor: AppColors.sage,
                child: const Padding(
                  padding: EdgeInsets.all(24),
                  child: SelectionArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PolicySection(
                          title: 'Dados armazenados',
                          body: 'Hábitos, preferências e sessões ficam somente no armazenamento local do seu dispositivo. O Aevum não exige conta.',
                        ),
                        _PolicySection(
                          title: 'Coleta e compartilhamento',
                          body: 'O Aevum não coleta, transmite, vende ou compartilha dados pessoais. Não há publicidade, analytics ou rastreamento.',
                        ),
                        _PolicySection(
                          title: 'Permissões',
                          body: 'O app pode usar vibração para fornecer retorno tátil durante uma sessão. Ele não solicita permissão de notificações.',
                        ),
                        _PolicySection(
                          title: 'Controle dos seus dados',
                          body: 'Você pode apagar todos os hábitos, sessões e preferências pela tela Sobre. Desinstalar o app também remove os dados locais.',
                        ),
                        _PolicySection(
                          title: 'Links externos',
                          body: 'Links opcionais para contato, código-fonte ou apoio abrem serviços externos, sujeitos às políticas desses serviços.',
                        ),
                        _PolicySection(
                          title: 'Contato',
                          body: 'O canal público de contato será informado nesta política e na página da Google Play antes do lançamento.',
                          last: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({
    required this.title,
    required this.body,
    this.last = false,
  });

  final String title;
  final String body;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.serif(
              size: 19,
              weight: FontWeight.w500,
              color: AppColors.sage,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            body,
            style: const TextStyle(
              color: AppColors.textMuted,
              height: 1.55,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
