import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intiface_central/bloc/util/navigation_cubit.dart';
import 'package:intiface_central/theme/cyberpunk.dart';
import 'package:intiface_central/util/intiface_localizations.dart';
import 'package:intiface_central/widget/cyberpunk/components.dart';
import 'package:sentry/sentry_io.dart';

/// 赛博朋克发送日志页面
///
/// 替代桌面端 SendLogsPage，适配深色赛博朋克主题。
class CyberpunkSendLogsPage extends StatefulWidget {
  const CyberpunkSendLogsPage({super.key});

  @override
  State<CyberpunkSendLogsPage> createState() => _CyberpunkSendLogsPageState();
}

class _CyberpunkSendLogsPageState extends State<CyberpunkSendLogsPage> {
  final _contactController = TextEditingController();
  final _textController = TextEditingController();

  @override
  void dispose() {
    _contactController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: CyberSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: CyberSpacing.lg),
            const Text(
              IntifaceLocalizations.sendLogsToDevs,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: CyberColors.textPrimary),
            ),
            const SizedBox(height: CyberSpacing.sm),
            const Text(
              IntifaceLocalizations.submitLogsDescription,
              style: TextStyle(fontSize: 12, color: CyberColors.textTertiary),
            ),
            const SizedBox(height: CyberSpacing.lg),
            // 联系方式输入
            TextField(
              controller: _contactController,
              style: const TextStyle(fontSize: 13, color: CyberColors.textSecondary),
              decoration: InputDecoration(
                hintText: IntifaceLocalizations.putContactInfo,
                hintStyle: TextStyle(color: CyberColors.textDisabled, fontSize: 13),
                filled: true,
                fillColor: Colors.white.withOpacity(0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(CyberRadius.input),
                  borderSide: BorderSide(color: CyberColors.glassBorderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(CyberRadius.input),
                  borderSide: BorderSide(color: CyberColors.glassBorderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(CyberRadius.input),
                  borderSide: const BorderSide(color: CyberColors.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: CyberSpacing.md),
            // 问题描述输入
            TextField(
              controller: _textController,
              minLines: 4,
              maxLines: null,
              style: const TextStyle(fontSize: 13, color: CyberColors.textSecondary),
              decoration: InputDecoration(
                hintText: IntifaceLocalizations.putIssueReport,
                hintStyle: TextStyle(color: CyberColors.textDisabled, fontSize: 13),
                filled: true,
                fillColor: Colors.white.withOpacity(0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(CyberRadius.input),
                  borderSide: BorderSide(color: CyberColors.glassBorderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(CyberRadius.input),
                  borderSide: BorderSide(color: CyberColors.glassBorderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(CyberRadius.input),
                  borderSide: const BorderSide(color: CyberColors.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: CyberSpacing.lg),
            // 发送按钮
            SizedBox(
              width: double.infinity,
              child: NeonButton(
                label: IntifaceLocalizations.sendLogs,
                icon: Icons.send_outlined,
                color: CyberColors.secondary,
                onPressed: () => _sendLogs(context),
              ),
            ),
            const SizedBox(height: CyberSpacing.xxl),
          ],
        ),
      ),
    );
  }

  void _sendLogs(BuildContext context) {
    var contactText = _contactController.value.text;
    var messageText = _textController.value.text;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        var contentText = IntifaceLocalizations.sendingLogs;
        var sendFinished = false;
        var sendFailed = false;
        var sendStarted = false;

        return StatefulBuilder(
          builder: (context, setState) {
            if (!sendStarted) {
              sendStarted = true;
              Sentry.captureMessage(
                """Contact Info: $contactText

Message:

$messageText""",
                withScope: (scope) {
                  scope.setTag("ManualLogSubmit", true.toString());
                },
              ).then((value) {
                setState(() {
                  contentText = IntifaceLocalizations.logsSent;
                  sendFinished = true;
                });
              }).onError((error, stackTrace) {
                setState(() {
                  contentText = IntifaceLocalizations.errorSendingLogs;
                  sendFinished = true;
                  sendFailed = true;
                });
              });
            }
            return AlertDialog(
              backgroundColor: const Color(0xFF0A0A1A),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(contentText, style: const TextStyle(color: CyberColors.textSecondary)),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: sendFinished
                      ? () {
                          Navigator.of(context).pop();
                          if (!sendFailed) {
                            BlocProvider.of<NavigationCubit>(context).goSettings();
                          }
                        }
                      : null,
                  child: Text(IntifaceLocalizations.ok),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
