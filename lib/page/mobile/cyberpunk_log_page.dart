import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intiface_central/bloc/configuration/intiface_configuration_cubit.dart';
import 'package:intiface_central/bloc/util/error_notifier_cubit.dart';
import 'package:intiface_central/theme/cyberpunk.dart';
import 'package:intiface_central/widget/cyberpunk/components.dart';
import 'package:intiface_central/widget/log/widgets/loggy_stream_widget.dart';
import 'package:loggy/loggy.dart';

/// 赛博朋克日志页面
///
/// 包含级别选择器下拉和彩色日志流。
class CyberpunkLogPage extends StatelessWidget {
  const CyberpunkLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<ErrorNotifierCubit>(context).clearError();
    final configCubit = BlocProvider.of<IntifaceConfigurationCubit>(context);

    return Column(
      children: [
        // 标题栏 + 级别选择器
        CyberHeader(
          title: '日志',
          subtitle: '闪动 · LOGS',
          subtitleColor: CyberColors.secondary,
          trailing: _LogLevelSelector(configCubit: configCubit),
        ),
        // 日志流
        Expanded(
          child: BlocBuilder<IntifaceConfigurationCubit, IntifaceConfigurationState>(
            buildWhen: (prev, curr) => curr is DisplayLogLevelState,
            builder: (context, state) {
              final level = LogLevel.values.firstWhere(
                (element) => element.name == configCubit.displayLogLevel,
                orElse: () => LogLevel.info,
              );
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: CyberSpacing.xl),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(CyberRadius.card),
                  child: LoggyStreamWidget(logLevel: level),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: CyberSpacing.sm),
      ],
    );
  }
}

/// 日志级别选择器
class _LogLevelSelector extends StatelessWidget {
  final IntifaceConfigurationCubit configCubit;

  const _LogLevelSelector({required this.configCubit});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IntifaceConfigurationCubit, IntifaceConfigurationState>(
      bloc: configCubit,
      buildWhen: (prev, curr) => curr is DisplayLogLevelState,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: CyberSpacing.lg, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(CyberRadius.small),
            border: Border.all(color: CyberColors.glassBorderSubtle),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: configCubit.displayLogLevel,
              isDense: true,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: CyberColors.textSecondary,
              ),
              dropdownColor: const Color(0xFF0A0A1A),
              icon: const Icon(Icons.expand_more, size: 16, color: CyberColors.textTertiary),
              items: LogLevel.values.map((level) {
                final labels = {
                  'trace': '追踪',
                  'debug': '调试',
                  'info': '信息',
                  'warning': '警告',
                  'error': '错误',
                };
                return DropdownMenuItem(
                  value: level.name,
                  child: Text(labels[level.name] ?? level.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) configCubit.displayLogLevel = value;
              },
            ),
          ),
        );
      },
    );
  }
}
