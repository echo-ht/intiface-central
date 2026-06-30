import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intiface_central/bloc/configuration/intiface_configuration_cubit.dart';
import 'package:intiface_central/bloc/engine/engine_control_bloc.dart';
import 'package:intiface_central/bloc/util/app_reset_cubit.dart';
import 'package:intiface_central/bloc/util/navigation_cubit.dart';
import 'package:intiface_central/theme/cyberpunk.dart';
import 'package:intiface_central/util/intiface_localizations.dart';
import 'package:intiface_central/util/intiface_util.dart';
import 'package:intiface_central/widget/cyberpunk/components.dart';
import 'package:loggy/loggy.dart';
import 'package:permission_handler/permission_handler.dart';

/// 赛博朋克设置页面
///
/// 包含版本信息、应用设置、高级功能、重置选项、关于与帮助。
class CyberpunkSettingsPage extends StatelessWidget {
  const CyberpunkSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<IntifaceConfigurationCubit>();
    final engineIsRunning = context.watch<EngineControlBloc>().isRunning;

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
            title: '设置',
            subtitle: '闪动 · SETTINGS',
            subtitleColor: CyberColors.accent,
          ),
          const SizedBox(height: CyberSpacing.lg),
          // 版本卡片
          _VersionCard(cubit: cubit),
          const SizedBox(height: CyberSpacing.lg),
          // 应用设置
          _AppSettingsCard(cubit: cubit),
          const SizedBox(height: CyberSpacing.lg),
          // 高级功能
          _AdvancedSettingsCard(cubit: cubit),
          const SizedBox(height: CyberSpacing.lg),
          // 移动端专属设置
          _MobileSettingsCard(cubit: cubit, engineIsRunning: engineIsRunning),
          if (Platform.isAndroid || Platform.isIOS) ...[
            const SizedBox(height: CyberSpacing.lg),
            const _PermissionsCard(),
          ],
          const SizedBox(height: CyberSpacing.lg),
          // 重置选项
          _ResetCard(cubit: cubit, engineIsRunning: engineIsRunning),
          const SizedBox(height: CyberSpacing.lg),
          // 关于与帮助
          const _AboutEntry(),
        ],
      ),
    );
  }
}

/// 版本信息卡片
class _VersionCard extends StatelessWidget {
  final IntifaceConfigurationCubit cubit;

  const _VersionCard({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      glowColor: CyberColors.accent,
      borderColor: CyberColors.accent.withOpacity(0.2),
      padding: const EdgeInsets.all(CyberSpacing.xl),
      child: Column(
        children: [
          // 应用图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: CyberColors.accent, width: 1.5),
            ),
            child: Icon(Icons.memory, color: CyberColors.accent, size: 22),
          ),
          const SizedBox(height: CyberSpacing.md),
          const Text(
            '闪动',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: CyberColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'v${cubit.currentAppVersion}',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: CyberColors.accent),
          ),
        ],
      ),
    );
  }
}

/// 应用设置卡片
class _AppSettingsCard extends StatelessWidget {
  final IntifaceConfigurationCubit cubit;

  const _AppSettingsCard({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: CyberSpacing.lg, vertical: CyberSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: CyberSpacing.sm, vertical: CyberSpacing.md),
            child: CyberCardTitle(text: '应用设置'),
          ),
          CyberSettingRow(
            icon: Icons.palette_outlined,
            label: IntifaceLocalizations.theme,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _themeLabel(cubit.themeModeSetting),
                  style: const TextStyle(fontSize: 13, color: CyberColors.textTertiary),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 12, color: Color(0xFF555566)),
              ],
            ),
            onTap: () => _showThemePicker(context, cubit),
          ),
          CyberSettingRow(
            icon: Icons.system_update_outlined,
            label: IntifaceLocalizations.checkUpdatesOnLaunch,
            trailing: CyberToggle(
              value: cubit.checkForUpdateOnStart,
              onChanged: (v) => cubit.checkForUpdateOnStart = v,
            ),
          ),
          CyberSettingRow(
            icon: Icons.bug_report_outlined,
            label: IntifaceLocalizations.crashReporting,
            trailing: CyberToggle(
              value: cubit.crashReporting,
              onChanged: cubit.canUseCrashReporting
                  ? (v) => cubit.crashReporting = v
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  String _themeLabel(String setting) {
    switch (setting) {
      case 'light':
        return IntifaceLocalizations.themeLight;
      case 'dark':
        return IntifaceLocalizations.themeDark;
      default:
        return IntifaceLocalizations.themeSystem;
    }
  }

  void _showThemePicker(BuildContext context, IntifaceConfigurationCubit cubit) {
    showDialog<void>(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: const Color(0xFF0A0A1A),
        title: const Text('外观主题', style: TextStyle(color: CyberColors.textPrimary)),
        children: [
          SimpleDialogOption(
            onPressed: () { cubit.themeModeSetting = 'system'; Navigator.pop(context); },
            child: const Text('跟随系统', style: TextStyle(color: CyberColors.textSecondary)),
          ),
          SimpleDialogOption(
            onPressed: () { cubit.themeModeSetting = 'light'; Navigator.pop(context); },
            child: const Text('浅色', style: TextStyle(color: CyberColors.textSecondary)),
          ),
          SimpleDialogOption(
            onPressed: () { cubit.themeModeSetting = 'dark'; Navigator.pop(context); },
            child: const Text('深色', style: TextStyle(color: CyberColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

/// 高级功能卡片
class _AdvancedSettingsCard extends StatelessWidget {
  final IntifaceConfigurationCubit cubit;

  const _AdvancedSettingsCard({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: CyberSpacing.lg, vertical: CyberSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: CyberSpacing.sm, vertical: CyberSpacing.md),
            child: const CyberCardTitle(text: IntifaceLocalizations.experimentalFeatures),
          ),
          CyberSettingRow(
            icon: Icons.api_outlined,
            label: IntifaceLocalizations.restServer,
            trailing: CyberToggle(
              value: cubit.allowExperimentalRestServer,
              onChanged: (v) => cubit.allowExperimentalRestServer = v,
            ),
          ),
        ],
      ),
    );
  }
}

/// 移动端专属设置卡片
class _MobileSettingsCard extends StatelessWidget {
  final IntifaceConfigurationCubit cubit;
  final bool engineIsRunning;

  const _MobileSettingsCard({required this.cubit, required this.engineIsRunning});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: CyberSpacing.lg, vertical: CyberSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: CyberSpacing.sm, vertical: CyberSpacing.md),
            child: CyberCardTitle(text: '移动端设置'),
          ),
          CyberSettingRow(
            icon: Icons.notification_important_outlined,
            label: IntifaceLocalizations.useForegroundProcess,
            iconColor: engineIsRunning ? CyberColors.textDisabled : null,
            trailing: CyberToggle(
              value: cubit.useForegroundProcess,
              onChanged: engineIsRunning
                  ? null
                  : (v) {
                      cubit.useForegroundProcess = v;
                      showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => AlertDialog(
                          title: Text(IntifaceLocalizations.appNeedsRestart),
                          content: const SingleChildScrollView(
                            child: ListBody(children: [Text(IntifaceLocalizations.foregroundRestartMessage)]),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(IntifaceLocalizations.ok),
                            ),
                          ],
                        ),
                      );
                    },
            ),
          ),
        ],
      ),
    );
  }
}

/// 权限设置卡片
class _PermissionsCard extends StatelessWidget {
  const _PermissionsCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: CyberSpacing.lg, vertical: CyberSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: CyberSpacing.sm, vertical: CyberSpacing.md),
            child: CyberCardTitle(text: '权限管理'),
          ),
          CyberSettingRow(
            icon: Icons.bluetooth_outlined,
            label: IntifaceLocalizations.requestBluetoothPermissions,
            trailing: const Icon(Icons.chevron_right, size: 12, color: Color(0xFF555566)),
            onTap: () async {
              if (Platform.isAndroid) {
                var statuses = await [Permission.bluetoothConnect, Permission.bluetoothScan].request();
                var allGranted = statuses.values.every((s) => s == PermissionStatus.granted);
                var anyPermanentlyDenied = statuses.values.any((s) => s == PermissionStatus.permanentlyDenied);
                if (anyPermanentlyDenied) {
                  await openAppSettings();
                } else if (allGranted && context.mounted) {
                  showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(IntifaceLocalizations.bluetoothPermissionsGranted),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(IntifaceLocalizations.ok),
                        ),
                      ],
                    ),
                  );
                }
              } else if (Platform.isIOS) {
                var status = await Permission.bluetooth.request();
                if (status == PermissionStatus.permanentlyDenied) {
                  await openAppSettings();
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

/// 重置选项卡片
class _ResetCard extends StatelessWidget {
  final IntifaceConfigurationCubit cubit;
  final bool engineIsRunning;

  const _ResetCard({required this.cubit, required this.engineIsRunning});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      glowColor: CyberColors.error,
      borderColor: CyberColors.error.withOpacity(0.15),
      padding: const EdgeInsets.symmetric(horizontal: CyberSpacing.lg, vertical: CyberSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: CyberSpacing.sm, vertical: CyberSpacing.md),
            child: CyberCardTitle(text: '重置选项', color: Color(0xFF996666)),
          ),
          CyberSettingRow(
            icon: Icons.cleaning_services_outlined,
            iconColor: CyberColors.error,
            label: IntifaceLocalizations.resetUserDeviceConfig,
            trailing: const Icon(Icons.chevron_right, size: 12, color: Color(0xFF885555)),
            onTap: engineIsRunning
                ? null
                : () => _confirmReset(context, isFullReset: false),
          ),
          CyberSettingRow(
            icon: Icons.restart_alt_outlined,
            iconColor: CyberColors.error,
            label: IntifaceLocalizations.resetAppConfig,
            trailing: const Icon(Icons.chevron_right, size: 12, color: Color(0xFF885555)),
            onTap: engineIsRunning
                ? null
                : () => _confirmReset(context, isFullReset: true),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, {required bool isFullReset}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(isFullReset
            ? IntifaceLocalizations.resetAppToDefaultsTitle
            : IntifaceLocalizations.resetUserDeviceConfigTitle),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text(isFullReset
                  ? IntifaceLocalizations.resetAppToDefaultsDesc
                  : IntifaceLocalizations.resetUserDeviceConfigDesc),
              Text(IntifaceLocalizations.wouldYouLikeToContinue),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(IntifaceLocalizations.cancel),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(dialogContext);
              final resetCubit = BlocProvider.of<AppResetCubit>(context);
              if (isFullReset) {
                logWarning("Running configuration reset");
                if (await IntifacePaths.deviceConfigFile.exists()) {
                  await IntifacePaths.deviceConfigFile.delete();
                }
                if (await IntifacePaths.newsFile.exists()) {
                  await IntifacePaths.newsFile.delete();
                }
                if (await IntifacePaths.userDeviceConfigFile.exists()) {
                  await IntifacePaths.userDeviceConfigFile.delete();
                }
                await cubit.reset();
                logWarning("Configuration reset finished");
              } else {
                logWarning("Running user device configuration reset");
                if (await IntifacePaths.userDeviceConfigFile.exists()) {
                  await IntifacePaths.userDeviceConfigFile.delete();
                }
                logWarning("User device configuration reset finished");
              }
              navigator.pop();
              resetCubit.reset();
            },
            style: TextButton.styleFrom(foregroundColor: CyberColors.error),
            child: Text(IntifaceLocalizations.ok),
          ),
        ],
      ),
    );
  }
}

/// 关于与帮助入口
class _AboutEntry extends StatelessWidget {
  const _AboutEntry();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => BlocProvider.of<NavigationCubit>(context).goAbout(),
      child: GlassCard(
        glowColor: CyberColors.accent,
        borderColor: CyberColors.accent.withOpacity(0.2),
        padding: const EdgeInsets.symmetric(horizontal: CyberSpacing.lg, vertical: CyberSpacing.lg),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 20, color: CyberColors.accent),
            const SizedBox(width: CyberSpacing.md),
            const Expanded(
              child: Text(
                IntifaceLocalizations.helpAbout,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFC0B0FF)),
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: CyberColors.accent),
          ],
        ),
      ),
    );
  }
}
