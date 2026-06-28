import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intiface_central/bloc/util/asset_cubit.dart';
import 'package:intiface_central/bloc/util/navigation_cubit.dart';
import 'package:intiface_central/theme/cyberpunk.dart';
import 'package:intiface_central/util/intiface_localizations.dart';
import 'package:intiface_central/widget/cyberpunk/components.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher_string.dart';

/// 赛博朋克关于/帮助页面
///
/// 替代桌面端 AboutHelpPage，适配深色赛博朋克主题。
class CyberpunkAboutPage extends StatelessWidget {
  const CyberpunkAboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    var assets = BlocProvider.of<AssetCubit>(context);
    return Expanded(
      child: Column(
        children: [
          // Markdown 内容
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: CyberSpacing.xl),
              child: MarkdownBody(
                data: assets.aboutAsset,
                selectable: true,
                onTapLink: (text, url, title) async {
                  if (url != null && await canLaunchUrlString(url)) {
                    launchUrlString(url);
                  }
                },
                extensionSet: md.ExtensionSet(
                  md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                  [
                    md.EmojiSyntax(),
                    ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
                  ],
                ),
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: CyberColors.textSecondary,
                  ),
                  h1: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: CyberColors.textPrimary,
                  ),
                  h2: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: CyberColors.textPrimary,
                  ),
                  h3: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: CyberColors.primary,
                  ),
                  a: const TextStyle(color: CyberColors.primary, decoration: TextDecoration.underline),
                  code: TextStyle(
                    fontSize: 13,
                    color: CyberColors.secondary,
                    backgroundColor: Colors.white.withOpacity(0.06),
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(CyberRadius.small),
                  ),
                  blockquoteDecoration: BoxDecoration(
                    border: Border(left: BorderSide(color: CyberColors.primary.withOpacity(0.4), width: 3)),
                    color: CyberColors.primary.withOpacity(0.04),
                  ),
                ),
              ),
            ),
          ),
          // 发送日志入口
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: CyberSpacing.xl, vertical: CyberSpacing.md),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: CyberSpacing.lg, vertical: CyberSpacing.md),
              onTap: () => BlocProvider.of<NavigationCubit>(context).goSendLogs(),
              child: Row(
                children: [
                  Icon(Icons.bug_report_outlined, size: 18, color: CyberColors.secondary),
                  const SizedBox(width: CyberSpacing.md),
                  const Expanded(
                    child: Text(
                      IntifaceLocalizations.sendLogsForSupport,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: CyberColors.textSecondary),
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 16, color: CyberColors.textTertiary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
