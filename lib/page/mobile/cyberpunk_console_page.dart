import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intiface_central/bloc/configuration/intiface_configuration_cubit.dart';
import 'package:intiface_central/bloc/engine/engine_control_bloc.dart';
import 'package:intiface_central/bloc/util/error_notifier_cubit.dart';
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: CyberSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CyberHeader(
                          title: '控制台',
                          subtitle: '闪动 · CONSOLE',
                        ),
                        const SizedBox(height: CyberSpacing.md),
                        _EngineControlCard(engineState: engineState),
                        const SizedBox(height: CyberSpacing.md),
                        _QuickActionsCard(),
                        const SizedBox(height: CyberSpacing.md),
                        _ModeTabs(),
                        const SizedBox(height: CyberSpacing.md),
                      ],
                    ),
                  ),
                  // 配置区域：整体可滚动，内层 SettingsList 用 shrinkWrap + NeverScrollable
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

/// 引擎控制卡片 — 紧凑横排：小圆形按钮 + 状态文本 + 服务器地址
class _EngineControlCard extends StatelessWidget {
  final EngineControlState engineState;

  const _EngineControlCard({required this.engineState});

  @override
  Widget build(BuildContext context) {
    final engineBloc = BlocProvider.of<EngineControlBloc>(context);
    final configCubit = BlocProvider.of<IntifaceConfigurationCubit>(context);
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

    return GlassCard(
      glowColor: isRunning ? CyberColors.primary : null,
      borderColor: isRunning
          ? CyberColors.primary.withOpacity(0.2)
          : CyberColors.glassBorder,
      padding: const EdgeInsets.fromLTRB(CyberSpacing.lg, CyberSpacing.md, CyberSpacing.lg, CyberSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 紧凑横排：小按钮 + 状态 + 错误
          Row(
            children: [
              // 小圆形按钮
              _CircularControlButton(
                isRunning: isRunning,
                isStarting: isStarting,
                statusColor: statusColor,
                size: 56,
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
              const SizedBox(width: CyberSpacing.lg),
              // 状态文本
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statusSubtext,
                      style: const TextStyle(
                        fontSize: 11,
                        color: CyberColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              // 错误图标
              BlocBuilder<ErrorNotifierCubit, ErrorNotifierState>(
                builder: (context, errorState) {
                  if (errorState is! ErrorNotifierTriggerState) {
                    return const SizedBox.shrink();
                  }
                  return GestureDetector(
                    onTap: () => navCubit.goLogs(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: CyberColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: CyberColors.error.withOpacity(0.3)),
                      ),
                      child: Icon(Icons.warning, size: 18, color: CyberColors.error),
                    ),
                  );
                },
              ),
            ],
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

/// 圆形控制按钮 — 霓虹发光，可调大小
class _CircularControlButton extends StatelessWidget {
  final bool isRunning;
  final bool isStarting;
  final Color statusColor;
  final VoidCallback? onPressed;
  final double size;

  const _CircularControlButton({
    required this.isRunning,
    required this.isStarting,
    required this.statusColor,
    required this.onPressed,
    this.size = 84,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = isRunning ? CyberColors.error : CyberColors.primary;
    final iconSize = size * 0.48;
    final padding = size * 0.28;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: buttonColor.withOpacity(0.15),
          border: Border.all(color: buttonColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: buttonColor.withOpacity(0.3),
              blurRadius: size * 0.24,
              spreadRadius: 0,
            ),
          ],
        ),
        child: isStarting
            ? Padding(
                padding: EdgeInsets.all(padding),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(buttonColor),
                ),
              )
            : Icon(
                isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded,
                size: iconSize,
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
    // EngineConfigWidget/RepeaterConfigWidget/RestApiConfigWidget 内部使用 Expanded
    // 并自带滚动，直接返回即可（外层已用 Expanded 包裹）
    return switch (configCubit.appMode) {
      AppMode.engine => const EngineConfigWidget(),
      AppMode.repeater => const RepeaterConfigWidget(),
      AppMode.restApi => const RestApiConfigWidget(),
    };
  }
}

/// 快捷操作卡片 — 连接震动 + 设备通知开关
class _QuickActionsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final configCubit = BlocProvider.of<IntifaceConfigurationCubit>(context);
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: CyberSpacing.md, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(CyberSpacing.sm, CyberSpacing.sm, CyberSpacing.sm, 4),
            child: CyberCardTitle(text: '快捷操作'),
          ),
          CyberSettingRow(
            icon: Icons.vibration,
            label: '连接即最强震动',
            iconColor: CyberColors.secondary,
            trailing: CyberToggle(
              value: configCubit.vibrateOnConnect,
              onChanged: (v) => configCubit.vibrateOnConnect = v,
              activeColor: CyberColors.secondary,
            ),
          ),
          CyberSettingRow(
            icon: Icons.notifications_active_outlined,
            label: '设备连接通知',
            iconColor: CyberColors.primary,
            trailing: CyberToggle(
              value: configCubit.notifyOnDeviceConnected,
              onChanged: (v) => configCubit.notifyOnDeviceConnected = v,
            ),
          ),
        ],
      ),
    );
  }
}
