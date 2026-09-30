import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aevum/core/config/app_links.dart';
import 'package:aevum/core/constants/app_colors.dart';
import 'package:aevum/core/providers/app_state_provider.dart';
import 'package:aevum/core/services/backup_codec.dart';
import 'package:aevum/core/widgets/forest_background.dart';
import 'package:aevum/core/theme/app_typography.dart';
import 'package:aevum/core/widgets/fade_slide_in.dart';
import 'package:aevum/core/widgets/glass_container.dart';
import 'package:aevum/core/widgets/glass_icon_button.dart';
import 'package:aevum/features/about/presentation/privacy_policy_screen.dart';
import 'package:aevum/features/tasks/providers/task_providers.dart';

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

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _exportBackup(BuildContext context, WidgetRef ref) async {
    final tasks = ref.read(taskListProvider);
    final sessions = ref.read(sessionListProvider);
    await Clipboard.setData(
      ClipboardData(text: BackupCodec.encode(tasks, sessions)),
    );
    if (!context.mounted) return;
    _showMessage(
      context,
      'Backup copiado. Cole em um lugar seguro, como uma nota sua.',
    );
  }

  Future<void> _importBackup(BuildContext context, WidgetRef ref) async {
    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
    if (!context.mounted) return;

    final BackupData backup;
    try {
      backup = BackupCodec.decode(clipboard?.text ?? '');
    } on FormatException {
      _showMessage(
        context,
        'Copie um backup do Aevum antes de importar: a área de transferência não tem um válido.',
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Importar backup?'),
        content: Text(
          '${backup.tasks.length} hábitos e ${backup.sessions.length} sessões serão adicionados. '
          'Itens que já existem serão atualizados e nada será apagado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Importar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await ref.read(taskListProvider.notifier).importTasks(backup.tasks);
    await ref
        .read(sessionListProvider.notifier)
        .importSessions(backup.sessions);
    if (!context.mounted) return;
    _showMessage(context, 'Backup importado.');
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
              const SizedBox(height: 18),
              FadeSlideIn(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.sage.withValues(alpha: 0.22),
                            blurRadius: 40,
                            spreadRadius: -8,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Image.asset(
                          'assets/app/aevum-mark.png',
                          width: 88,
                          height: 88,
                          cacheWidth: 264,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Aevum',
                      style: AppTypography.serif(
                        size: 38,
                        weight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Evolua no seu tempo',
                      style: AppTypography.serif(
                        size: 17,
                        color: AppColors.sage,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Hábitos saudáveis com constância tranquila, sem transformar o progresso em uma corrida.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                          height: 1.55,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              FadeSlideIn(
                index: 1,
                child: _AboutSection(
                  title: 'Privacidade',
                  children: [
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
                  ],
                ),
              ),

              FadeSlideIn(
                index: 2,
                child: _AboutSection(
                  title: 'Seus dados',
                  children: [
                    _AboutAction(
                      icon: Icons.upload_rounded,
                      title: 'Exportar backup',
                      subtitle: 'Copia hábitos e sessões como texto',
                      onTap: () => _exportBackup(context, ref),
                    ),
                    _AboutAction(
                      icon: Icons.download_rounded,
                      title: 'Importar backup',
                      subtitle:
                          'Lê o backup copiado para a área de transferência',
                      onTap: () => _importBackup(context, ref),
                    ),
                    _AboutAction(
                      icon: Icons.delete_forever_outlined,
                      title: 'Apagar todos os dados',
                      subtitle: 'Remove hábitos, sessões e preferências',
                      color: AppColors.warning,
                      onTap: () => _confirmReset(context, ref),
                    ),
                  ],
                ),
              ),

              FadeSlideIn(
                index: 3,
                child: _AboutSection(
                  title: 'Projeto',
                  children: [
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
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Feito com cuidado, aberto e independente.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textFaint, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grupo de ações numa única superfície de vidro, com divisórias finas.
class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
            child: Text(title.toUpperCase(), style: AppTypography.eyebrow),
          ),
          GlassContainer(
            borderRadius: 24,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0)
                    Divider(
                      indent: 62,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  children[i],
                ],
              ],
            ),
          ),
        ],
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
    this.color = AppColors.sage,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDestructive = color == AppColors.warning;
    return Material(
      color: Colors.transparent,
      child: ListTile(
        minTileHeight: 60,
        contentPadding: const EdgeInsets.fromLTRB(14, 4, 12, 4),
        leading: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            color: color.withValues(alpha: 0.12),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Text(
          title,
          style: isDestructive ? TextStyle(color: color) : null,
        ),
        subtitle: subtitle == null ? null : Text(subtitle!),
        trailing: onTap == null
            ? null
            : const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textFaint,
              ),
        onTap: onTap,
      ),
    );
  }
}
