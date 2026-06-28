import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intiface_central/bloc/configuration/intiface_configuration_cubit.dart';
import 'package:intiface_central/bloc/engine/engine_control_bloc.dart';
import 'package:intiface_central/bloc/util/error_notifier_cubit.dart';
import 'package:intiface_central/bloc/util/network_info_cubit.dart';
import 'package:intiface_central/bloc/util/navigation_cubit.dart';
import 'package:intiface_central/theme/cyberpunk.dart';
import 'package:intiface_central/util/bluetooth_check.dart';
import 'package:intiface_central/util/intiface_localizations.dart';
import 'package:intiface_central/widget/cyberpunk/components.dart';
import 'package:intiface_central/widget/engine_config_widget.dart';
import 'package:intiface_central/widget/repeater_config_widget.dart';
import 'package:intiface_central/widget/rest_api_config_widget.dart';

/// 赛博朋克控制台页面
///
/// 包含：引擎控制卡片(圆形播放/停止按钮)、模式标签(引擎/中继/REST)、
/// 以及对应模式的配置区域。
class CyberpunkConsolePage extends StatelessWidget {
  const CyberpunkConsolePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IntifaceConfigurationCubit, IntifaceConfigurationState>(
      buildWhen: (prev, curr) => curr is AppModeState,
      builder: (context, configState) {
        return BlocConsumer<EngineControlBloc, EngineControlState>(
          listenWhen: (prev, curr) => curr is EnginePortInUseState,
          listener: (context, state) {
            _showPortInUseDialog(context, state as EnginePortInUseState);
          },
          buildWhen: (prev, curr) =>
              curr is EngineStartingState ||
              curr is EngineStartedState ||
              curr is EngineServerCreatedState ||
              curr is EngineStoppedState ||
              curr is ClientConnectedState ||
              curr is ClientDisconnectedState,
          builder: (context, engineState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: CyberSpacing.xl,
                right: CyberSpacing.xl,
                bottom: CyberSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CyberHeader(
                    title: '控制台',
                    subtitle: 'INTIFACE · CONSOLE',
                  ),
                  const SizedBox(height: CyberSpacing.lg),
                  _EngineControlCard(engineState: engineState),
                  const SizedBox(height: CyberSpacing.lg),
                  _ModeTabs(),
                  const SizedBox(height: CyberSpacing.lg),
                  _ModeConfigArea(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPortInUseDialog(BuildContext context, EnginePortInUseState state) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('端口被占用'),
        content: Text([
          '引擎错误: ${state.error}',
          if (state.address != null) '地址: ${state.address}',
          if (state.port != null) '端口: ${state.port}',
        ].join('\n')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(IntifaceLocalizations.ok),
          ),
        ],
      ),
    );
  }
}

/// 引擎控制卡片 — 圆形霓虹按钮 + 状态 + 服务器地址
class _EngineControlCard extends StatelessWidget {
  final EngineControlState engineState;

  const _EngineControlCard({required this.engineState});

  @override
  Widget build(BuildContext context) {
    final engineBloc = BlocProvider.of<EngineControlBloc>(context);
    final configCubit = BlocProvider.of<IntifaceConfigurationCubit>(context);
    final networkCubit = BlocProvider.of<NetworkInfoCubit>(context);
    final navCubit = BlocProvider.of<NavigationCubit>(context);

    final isRunning = engineState is! EngineStoppedState &&
        engineState is! EngineStartingState;
    final isStarting = engineState is EngineStartingState;

    // 状态文本
    String statusText;
    String statusSubtext;
    Color statusColor;
    if (engineState is ClientConnectedState) {
      statusText = (engineState as ClientConnectedState).clientName;
      statusSubtext = '客户端已连接';
      statusColor = CyberColors.success;
    } else if (engineState is EngineServerCreatedState ||
        engineState is ClientDisconnectedState) {
      statusText = IntifaceLocalizations.serverRunningNoClient;
      statusSubtext = '等待客户端连接';
      statusColor = CyberColors.primary;
    } else if (engineState is EngineStartedState) {
      statusText = IntifaceLocalizations.serverStarted;
      statusSubtext = '服务启动中';
      statusColor = CyberColors.primary;
    } else if (engineState is EngineStartingState) {
      statusText = IntifaceLocalizations.serverStarting;
      statusSubtext = '请稍候...';
      statusColor = CyberColors.warning;
    } else {
      statusText = IntifaceLocalizations.serverNotRunning;
      statusSubtext = '点击启动服务';
      statusColor = CyberColors.textDisabled;
    }

    // 服务器地址
    String serverAddress = '';
    if (configCubit.appMode == AppMode.engine) {
      final host = configCubit.websocketServerAllInterfaces
          ? (networkCubit.ip ?? '0.0.0.0')
          : 'localhost';
      serverAddress = 'ws://$host:${configCubit.websocketServerPort}';
    }

    return GlassCard(
      glowColor: isRunning ? CyberColors.primary : null,
      borderColor: isRunning
          ? CyberColors.primary.withOpacity(0.2)
          : CyberColors.glassBorder,
      padding: const EdgeInsets.all(CyberSpacing.xl),
      child: Column(
        children: [
          // 圆形播放/停止按钮
          _CircularControlButton(
            isRunning: isRunning,
            isStarting: isStarting,
            statusColor: statusColor,
            onPressed: isStarting
                ? null
                : () {
                    if (isRunning) {
                      engineBloc.add(EngineControlEventStop());
                    } else {
                      _startEngine(context, engineBloc, configCubit);
                    }
                  },
          ),
          const SizedBox(height: CyberSpacing.xl),
          // 状态文本
          Text(
            statusText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            statusSubtext,
            style: const TextStyle(
              fontSize: 12,
              color: CyberColors.textTertiary,
            ),
          ),
          // 服务器地址
          if (serverAddress.isNotEmpty) ...[
            const SizedBox(height: CyberSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: CyberSpacing.lg,
                vertical: CyberSpacing.md,
              ),
              decoration: BoxDecoration(
                color: CyberColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(CyberRadius.input),
                border: Border.all(
                  color: CyberColors.primary.withOpacity(0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.cloud, size: 16, color: CyberColors.primary.withOpacity(0.7)),
                  const SizedBox(width: CyberSpacing.sm),
                  Expanded(
                    child: Text(
                      serverAddress,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: CyberColors.primary.withOpacity(0.9),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // 错误指示器
          BlocBuilder<ErrorNotifierCubit, ErrorNotifierState>(
            builder: (context, errorState) {
              if (errorState is! ErrorNotifierTriggerState) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: CyberSpacing.md),
                child: GestureDetector(
                  onTap: () => navCubit.goLogs(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: CyberSpacing.lg,
                      vertical: CyberSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: CyberColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(CyberRadius.input),
                      border: Border.all(
                        color: CyberColors.error.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning, size: 16, color: CyberColors.error),
                        const SizedBox(width: CyberSpacing.sm),
                        Text(
                          IntifaceLocalizations.error,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: CyberColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _startEngine(
    BuildContext context,
    EngineControlBloc bloc,
    IntifaceConfigurationCubit configCubit,
  ) async {
    var btProblem = await checkBluetoothReady();
    if (btProblem != null) {
      if (!context.mounted) return;
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(IntifaceLocalizations.bluetoothNotReady),
          content: Text(btProblem),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(IntifaceLocalizations.ok),
            ),
          ],
        ),
      );
      return;
    }
    bloc.add(EngineControlEventStart(options: await configCubit.getEngineOptions()));
  }
}

/// 圆形控制按钮 — 霓虹发光
class _CircularControlButton extends StatelessWidget {
  final bool isRunning;
  final bool isStarting;
  final Color statusColor;
  final VoidCallback? onPressed;

  const _CircularControlButton({
    required this.isRunning,
    required this.isStarting,
    required this.statusColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = isRunning ? CyberColors.error : CyberColors.primary;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: buttonColor.withOpacity(0.15),
          border: Border.all(color: buttonColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: buttonColor.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: isStarting
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(buttonColor),
                ),
              )
            : Icon(
                isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded,
                size: 40,
                color: buttonColor,
              ),
      ),
    );
  }
}

/// 模式标签 — 引擎/中继/REST
class _ModeTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final configCubit = BlocProvider.of<IntifaceConfigurationCubit>(context);
    final engineBloc = BlocProvider.of<EngineControlBloc>(context);
    final engineStopped = engineBloc.state is EngineStoppedState;

    final modes = [AppMode.engine, AppMode.repeater];
    if (configCubit.allowExperimentalRestServer) {
      modes.add(AppMode.restApi);
    }

    final labels = {
      AppMode.engine: '引擎',
      AppMode.repeater: '中继',
      AppMode.restApi: 'REST',
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(CyberRadius.input),
        border: Border.all(color: CyberColors.glassBorderSubtle),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: modes.map((mode) {
          final isActive = configCubit.appMode == mode;
          return Expanded(
            child: GestureDetector(
              onTap: engineStopped
                  ? () => configCubit.appMode = mode
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive
                      ? CyberColors.primary.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(CyberRadius.small),
                  border: isActive
                      ? Border.all(color: CyberColors.primary.withOpacity(0.4))
                      : Border.all(color: Colors.transparent),
                ),
                child: Text(
                  labels[mode]!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive
                        ? CyberColors.primary
                        : CyberColors.textDisabled,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// 模式配置区域
class _ModeConfigArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final configCubit = BlocProvider.of<IntifaceConfigurationCubit>(context);
    // flutter_settings_ui 组件自带滚动和主题，直接渲染
    // 通过 cyberpunk dark theme 自动适配深色风格
    return switch (configCubit.appMode) {
      AppMode.engine => const EngineConfigWidget(),
      AppMode.repeater => const RepeaterConfigWidget(),
      AppMode.restApi => const RestApiConfigWidget(),
    };
  }
}
