import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aevum/core/config/app_links.dart';
import 'package:aevum/core/constants/app_colors.dart';
import 'package:aevum/core/providers/app_state_provider.dart';
import 'package:aevum/core/widgets/forest_background.dart';
import 'package:aevum/core/widgets/glass_container.dart';
import 'package:aevum/features/about/presentation/privacy_policy_screen.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  Future<void> _openLink(BuildContext context, String value) async {
    final uri = Uri.tryParse(value);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir este link.')),
      );
    }
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Apagar todos os dados?'),
        content: const Text(
          'Hábitos, sessões e preferências serão removidos deste aparelho. Essa ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Apagar tudo',
              style: TextStyle(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await ref.read(appStateProvider.notifier).resetAllData();
    if (!context.mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ForestBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              const SliverAppBar(
                backgroundColor: Colors.transparent,
                title: Text('Sobre o Aevum'),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                sliver: SliverList.list(
                  children: [
                    GlassContainer(
                      strong: true,
                      borderRadius: 30,
                      accentColor: AppColors.sage,
                      child: const Padding(
                        padding: EdgeInsets.all(26),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.all(
                                Radius.circular(22),
                              ),
                              child: Image(
                                image: AssetImage('assets/app/aevum-mark.png'),
                                width: 80,
                                height: 80,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Aevum',
                              style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Evolua no seu tempo',
                              style: TextStyle(
                                color: AppColors.sage,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Hábitos saudáveis com constância tranquila, sem transformar o progresso em uma corrida.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _AboutAction(
                      icon: Icons.shield_outlined,
                      title: 'Política de Privacidade',
                      subtitle: 'Seus dados permanecem neste aparelho',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen(),
                        ),
                      ),
                    ),
                    if (AppLinks.isConfigured(AppLinks.privacyPolicyUrl))
                      _AboutAction(
                        icon: Icons.open_in_new_rounded,
                        title: 'Política de privacidade online',
                        onTap: () =>
                            _openLink(context, AppLinks.privacyPolicyUrl),
                      ),
                    _AboutAction(
                      icon: Icons.balance_rounded,
                      title: 'Licença MIT',
                      subtitle:
                          'Software aberto por Matheus Fernandes da Silva',
                      onTap: () async {
                        final info = await PackageInfo.fromPlatform();
                        if (!context.mounted) return;
                        showLicensePage(
                          context: context,
                          applicationName: 'Aevum',
                          applicationVersion: info.version,
                          applicationLegalese:
                              '© 2026 Matheus Fernandes da Silva · Licença MIT',
                        );
                      },
                    ),
                    if (AppLinks.isConfigured(AppLinks.sourceCodeUrl))
                      _AboutAction(
                        icon: Icons.code_rounded,
                        title: 'Código-fonte',
                        onTap: () => _openLink(context, AppLinks.sourceCodeUrl),
                      ),
                    if (AppLinks.isConfigured(AppLinks.contactUrl))
                      _AboutAction(
                        icon: Icons.mail_outline_rounded,
                        title: 'Contato',
                        onTap: () => _openLink(context, AppLinks.contactUrl),
                      ),
                    if (AppLinks.isConfigured(AppLinks.supportUrl))
                      _AboutAction(
                        icon: Icons.local_cafe_outlined,
                        title: 'Apoie o projeto',
                        subtitle:
                            'Contribuição voluntária, sem recompensas digitais',
                        onTap: () => _openLink(context, AppLinks.supportUrl),
                      ),
                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) => _AboutAction(
                        icon: Icons.info_outline_rounded,
                        title: 'Versão',
                        subtitle: snapshot.hasData
                            ? '${snapshot.data!.version} (${snapshot.data!.buildNumber})'
                            : 'Carregando…',
                      ),
                    ),
                    const SizedBox(height: 18),
                    OutlinedButton.icon(
                      onPressed: () => _confirmReset(context, ref),
                      icon: const Icon(Icons.delete_forever_outlined),
                      label: const Text('Apagar todos os dados'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.warning,
                        minimumSize: const Size.fromHeight(52),
                        side: const BorderSide(color: AppColors.warning),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Feito com cuidado, aberto e independente.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted),
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

class _AboutAction extends StatelessWidget {
  const _AboutAction({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassContainer(
        borderRadius: 18,
        child: ListTile(
          minTileHeight: 56,
          leading: Icon(icon, color: AppColors.sage),
          title: Text(title),
          subtitle: subtitle == null ? null : Text(subtitle!),
          trailing: onTap == null
              ? null
              : const Icon(Icons.chevron_right_rounded),
          onTap: onTap,
        ),
      ),
    );
  }
}
