import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intiface_central/bloc/device/device_manager_bloc.dart';
import 'package:intiface_central/bloc/device_configuration/user_device_configuration_cubit.dart';
import 'package:intiface_central/bloc/engine/engine_control_bloc.dart';
import 'package:intiface_central/page/add_device_type_page.dart';
import 'package:intiface_central/page/add_serial_device_page.dart';
import 'package:intiface_central/page/add_simulated_device_page.dart';
import 'package:intiface_central/page/add_websocket_device_page.dart';
import 'package:intiface_central/page/device_detail_page.dart';
import 'package:intiface_central/src/rust/api/device_config.dart';
import 'package:intiface_central/theme/cyberpunk.dart';
import 'package:intiface_central/util/intiface_localizations.dart';
import 'package:intiface_central/widget/cyberpunk/components.dart';

/// 赛博朋克设备页面
///
/// 包含设备列表(扫描按钮、允许模式横幅、设备卡片、添加设备按钮)
/// 和设备详情(通过子页面导航)。
class CyberpunkDevicePage extends StatefulWidget {
  const CyberpunkDevicePage({super.key});

  @override
  State<CyberpunkDevicePage> createState() => _CyberpunkDevicePageState();
}

enum _DeviceSubPage {
  list,
  detail,
  addType,
  addWebsocket,
  addSerial,
  addSimulated,
}

class _CyberpunkDevicePageState extends State<CyberpunkDevicePage> {
  _DeviceSubPage _currentPage = _DeviceSubPage.list;
  ExposedUserDeviceIdentifier? _selectedIdentifier;

  void _goToDetail(ExposedUserDeviceIdentifier identifier) {
    setState(() {
      _currentPage = _DeviceSubPage.detail;
      _selectedIdentifier = identifier;
    });
  }

  void _goToAddType() => setState(() => _currentPage = _DeviceSubPage.addType);
  void _goBack() => setState(() {
    _currentPage = _DeviceSubPage.list;
    _selectedIdentifier = null;
  });
  void _goBackToAddType() => setState(() => _currentPage = _DeviceSubPage.addType);

  @override
  Widget build(BuildContext context) {
    return switch (_currentPage) {
      _DeviceSubPage.list => _CyberpunkDeviceListView(
          onDeviceTap: _goToDetail,
          onAddDeviceTap: _goToAddType,
        ),
      _DeviceSubPage.detail => _CyberpunkDeviceDetailWrapper(
          identifier: _selectedIdentifier!,
          onBack: _goBack,
        ),
      _DeviceSubPage.addType => AddDeviceTypePage(
          onBack: _goBack,
          onWebsocket: () => setState(() => _currentPage = _DeviceSubPage.addWebsocket),
          onSerial: () => setState(() => _currentPage = _DeviceSubPage.addSerial),
          onSimulated: () => setState(() => _currentPage = _DeviceSubPage.addSimulated),
        ),
      _DeviceSubPage.addWebsocket => AddWebsocketDevicePage(onBack: _goBackToAddType),
      _DeviceSubPage.addSerial => AddSerialDevicePage(onBack: _goBackToAddType),
      _DeviceSubPage.addSimulated => AddSimulatedDevicePage(onBack: _goBackToAddType),
    };
  }
}

/// 设备详情包裹器 — 添加赛博朋克标题栏
class _CyberpunkDeviceDetailWrapper extends StatelessWidget {
  final ExposedUserDeviceIdentifier identifier;
  final VoidCallback onBack;

  const _CyberpunkDeviceDetailWrapper({
    required this.identifier,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 赛博朋克标题栏
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: CyberSpacing.lg, vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_left, color: CyberColors.textSecondary),
                ),
              ),
              const SizedBox(width: CyberSpacing.md),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('设备详情', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: CyberColors.textPrimary)),
                    Text('DEVICE · DETAIL', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: CyberColors.primary, letterSpacing: 2)),
                  ],
                ),
              ),
            ],
          ),
        ),
        // 原有详情页
        Expanded(child: DeviceDetailPage(identifier: identifier, onBack: onBack)),
      ],
    );
  }
}

/// 赛博朋克设备列表视图
class _CyberpunkDeviceListView extends StatelessWidget {
  final void Function(ExposedUserDeviceIdentifier identifier) onDeviceTap;
  final VoidCallback onAddDeviceTap;

  const _CyberpunkDeviceListView({
    required this.onDeviceTap,
    required this.onAddDeviceTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EngineControlBloc, EngineControlState>(
      buildWhen: (prev, curr) =>
          curr is DeviceConnectedState ||
          curr is DeviceDisconnectedState ||
          curr is ClientDisconnectedState ||
          curr is EngineStoppedState,
      builder: (context, engineState) {
        final deviceBloc = BlocProvider.of<DeviceManagerBloc>(context);
        final engineRunning = engineState is! EngineStoppedState;

        return BlocBuilder<DeviceManagerBloc, DeviceManagerState>(
          builder: (context, state) {
            return BlocBuilder<UserDeviceConfigurationCubit, UserDeviceConfigurationState>(
              builder: (context, userConfigState) {
                final userConfigCubit = BlocProvider.of<UserDeviceConfigurationCubit>(context);
                final connectedDevices = deviceBloc.devices;
                final connectedIndexes = connectedDevices.map((d) => d.device!.index).toSet();
                final anyAllowed = userConfigCubit.configs.values.any((def) => def.allow);

                final sortedEntries = userConfigCubit.configs.entries.toList();
                sortedEntries.sort((a, b) {
                  final aConnected = connectedIndexes.contains(a.value.index);
                  final bConnected = connectedIndexes.contains(b.value.index);
                  if (aConnected != bConnected) return aConnected ? -1 : 1;
                  final aName = (a.value.displayName ?? a.value.name).toLowerCase();
                  final bName = (b.value.displayName ?? b.value.name).toLowerCase();
                  return aName.compareTo(bName);
                });

                return Column(
                  children: [
                    // 标题栏 + 扫描按钮
                    CyberHeader(
                      title: '设备',
                      subtitle: 'INTIFACE · DEVICES',
                      trailing: _ScanButton(
                        scanning: deviceBloc.scanning,
                        engineRunning: engineRunning,
                        onStart: () => deviceBloc.add(DeviceManagerStartScanningEvent()),
                        onStop: () => deviceBloc.add(DeviceManagerStopScanningEvent()),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: CyberSpacing.xl, vertical: CyberSpacing.sm),
                        children: [
                          // 允许模式横幅
                          if (anyAllowed) ...[
                            const _AllowModeBanner(),
                            const SizedBox(height: CyberSpacing.lg),
                          ],
                          // 设备卡片列表
                          if (sortedEntries.isEmpty)
                            _NoDevicesView(onAddDeviceTap: onAddDeviceTap)
                          else
                            ...sortedEntries.map((entry) {
                              final isConnected = connectedIndexes.contains(entry.value.index);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: CyberSpacing.md),
                                child: _CyberDeviceCard(
                                  identifier: entry.key,
                                  definition: entry.value,
                                  isConnected: isConnected,
                                  onTap: () => onDeviceTap(entry.key),
                                ),
                              );
                            }),
                          // 添加设备按钮
                          const SizedBox(height: CyberSpacing.md),
                          _AddDeviceButton(
                            enabled: !engineRunning,
                            onTap: onAddDeviceTap,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

/// 扫描按钮
class _ScanButton extends StatelessWidget {
  final bool scanning;
  final bool engineRunning;
  final VoidCallback onStart;
  final VoidCallback onStop;

  const _ScanButton({
    required this.scanning,
    required this.engineRunning,
    required this.onStart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final canScan = engineRunning && !scanning;
    return NeonButton(
      label: scanning ? '停止' : '扫描',
      icon: scanning ? Icons.stop_rounded : Icons.radar_rounded,
      onPressed: canScan || scanning ? (scanning ? onStop : onStart) : null,
      height: 40,
    );
  }
}

/// 允许模式横幅
class _AllowModeBanner extends StatelessWidget {
  const _AllowModeBanner();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: CyberSpacing.lg, vertical: CyberSpacing.md),
      glowColor: CyberColors.success,
      borderColor: CyberColors.success.withOpacity(0.3),
      borderRadius: CyberRadius.input,
      child: Row(
        children: [
          Icon(Icons.shield_outlined, size: 16, color: CyberColors.success),
          const SizedBox(width: CyberSpacing.sm),
          Expanded(
            child: Text(
              IntifaceLocalizations.allowModeActive,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: CyberColors.success),
            ),
          ),
          Icon(Icons.chevron_right, size: 16, color: CyberColors.success),
        ],
      ),
    );
  }
}

/// 赛博朋克设备卡片
class _CyberDeviceCard extends StatelessWidget {
  final ExposedUserDeviceIdentifier identifier;
  final ExposedServerDeviceDefinition definition;
  final bool isConnected;
  final VoidCallback onTap;

  const _CyberDeviceCard({
    required this.identifier,
    required this.definition,
    required this.isConnected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = definition.displayName ?? definition.name;
    final isAllowed = definition.allow;

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        glowColor: isConnected
            ? (isAllowed ? CyberColors.success : CyberColors.secondary)
            : null,
        borderColor: isConnected
            ? (isAllowed
                ? CyberColors.success.withOpacity(0.2)
                : CyberColors.secondary.withOpacity(0.2))
            : CyberColors.glassBorderSubtle,
        padding: const EdgeInsets.all(CyberSpacing.lg),
        child: Column(
          children: [
            Row(
              children: [
                // 设备图标
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isConnected
                        ? (isAllowed ? CyberColors.primary : CyberColors.secondary).withOpacity(0.15)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(CyberRadius.input),
                    border: Border.all(
                      color: isConnected
                          ? (isAllowed ? CyberColors.primary : CyberColors.secondary).withOpacity(0.4)
                          : Colors.white.withOpacity(0.15),
                    ),
                  ),
                  child: Icon(
                    Icons.bluetooth_connected,
                    size: 20,
                    color: isConnected
                        ? (isAllowed ? CyberColors.primary : CyberColors.secondary)
                        : CyberColors.textDisabled,
                  ),
                ),
                const SizedBox(width: CyberSpacing.md),
                // 名称 + 功能图标
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isConnected ? CyberColors.textPrimary : CyberColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.vibration, size: 12, color: CyberColors.secondary.withOpacity(0.7)),
                          const SizedBox(width: 4),
                          Text(
                            isConnected ? '已连接' : '未连接',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isConnected
                                  ? (isAllowed ? CyberColors.primary : CyberColors.secondary)
                                  : CyberColors.textDisabled,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 允许/拒绝徽章
                if (isConnected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: (isAllowed ? CyberColors.success : CyberColors.error).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(CyberRadius.pill),
                      border: Border.all(
                        color: (isAllowed ? CyberColors.success : CyberColors.error).withOpacity(0.4),
                      ),
                    ),
                    child: Text(
                      isAllowed ? '允许' : '拒绝',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isAllowed ? CyberColors.success : CyberColors.error,
                      ),
                    ),
                  ),
              ],
            ),
            // 电池条已移至详情页 (通过 DeviceInputBloc 获取)
          ],
        ),
      ),
    );
  }
}

/// 空设备视图
class _NoDevicesView extends StatelessWidget {
  final VoidCallback onAddDeviceTap;

  const _NoDevicesView({required this.onAddDeviceTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: CyberSpacing.xxxl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.vibration, size: 48, color: CyberColors.textDisabled.withOpacity(0.5)),
            const SizedBox(height: CyberSpacing.md),
            const Text(
              IntifaceLocalizations.noDevicesAvailable,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: CyberColors.textSecondary),
            ),
            const SizedBox(height: 6),
            const Text(
              IntifaceLocalizations.startEngineToConnect,
              style: TextStyle(fontSize: 13, color: CyberColors.textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// 添加设备按钮
class _AddDeviceButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _AddDeviceButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(CyberRadius.input),
          border: Border.all(
            color: enabled
                ? CyberColors.primary.withOpacity(0.3)
                : CyberColors.textDisabled.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 18, color: enabled ? CyberColors.primary : CyberColors.textDisabled),
            const SizedBox(width: CyberSpacing.sm),
            Text(
              IntifaceLocalizations.manageAdvancedDevices,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: enabled ? CyberColors.primary : CyberColors.textDisabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
