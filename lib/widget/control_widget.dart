import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intiface_central/bloc/configuration/intiface_configuration_cubit.dart';
import 'package:intiface_central/bloc/engine/engine_control_bloc.dart';
import 'package:intiface_central/bloc/util/error_notifier_cubit.dart';
import 'package:intiface_central/bloc/util/navigation_cubit.dart';
import 'package:intiface_central/bloc/util/network_info_cubit.dart';
import 'package:intiface_central/util/bluetooth_check.dart';
import 'package:intiface_central/util/docs_screenshot_keys.dart';
import 'package:intiface_central/util/intiface_util.dart';
import 'package:loggy/loggy.dart';
import 'package:intiface_central/util/intiface_localizations.dart';
import 'package:url_launcher/url_launcher_string.dart';

const _portInUseTroubleshootingUrl =
    'https://intiface.com/docs/intiface-central/troubleshooting';

Future<void> _showPortInUseDialog(
  BuildContext context,
  EnginePortInUseState state,
) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Port in use'),
      content: Text(
        [
          'Engine error: ${state.error}',
          if (state.address != null) 'Address: ${state.address}',
          if (state.port != null) 'Port: ${state.port}',
        ].join('\n'),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            if (await canLaunchUrlString(_portInUseTroubleshootingUrl)) {
              await launchUrlString(_portInUseTroubleshootingUrl);
            }
          },
          child: const Text(IntifaceLocalizations.openTroubleshooting),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text(IntifaceLocalizations.ok),
        ),
      ],
    ),
  );
}

class ControlWidget extends StatelessWidget {
  const ControlWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IntifaceConfigurationCubit, IntifaceConfigurationState>(
      buildWhen: (previous, current) => current is AppModeState,
      builder: (context, configState) {
        return BlocConsumer<EngineControlBloc, EngineControlState>(
          listenWhen: (previous, current) => current is EnginePortInUseState,
          listener: (context, state) {
            _showPortInUseDialog(context, state as EnginePortInUseState);
          },
          buildWhen:
              (EngineControlState previous, EngineControlState current) =>
                  current is EngineStartingState ||
                  current is EngineStartedState ||
                  current is EngineServerCreatedState ||
                  current is EngineStoppedState ||
                  current is ClientConnectedState ||
                  current is ClientDisconnectedState,
          builder: (context, EngineControlState state) {
            var engineControlBloc = BlocProvider.of<EngineControlBloc>(context);
            var navCubit = BlocProvider.of<NavigationCubit>(context);

            var statusMessage = IntifaceLocalizations.unknownStatus;
            var statusIcon = Icons.question_mark;
            var networkCubit = BlocProvider.of<NetworkInfoCubit>(context);
            var configCubit = BlocProvider.of<IntifaceConfigurationCubit>(
              context,
            );
            final ColorScheme colors = Theme.of(context).colorScheme;
            void Function()? buttonAction = () =>
                engineControlBloc.add(EngineControlEventStop());
            if (state is ClientConnectedState) {
              statusMessage = state.clientName;
              statusIcon = Icons.phone_in_talk;
            } else if (state is ClientDisconnectedState ||
                state is EngineServerCreatedState) {
              statusMessage = IntifaceLocalizations.serverRunningNoClient;
              statusIcon = Icons.phone_disabled;
              // Once we're in this state the engine is started.
              buttonAction = () =>
                  engineControlBloc.add(EngineControlEventStop());
            } else if (state is EngineStartedState) {
              statusMessage = IntifaceLocalizations.serverStarted;
              statusIcon = Icons.bedtime;
              buttonAction = () =>
                  engineControlBloc.add(EngineControlEventStop());
            } else if (state is EngineStoppedState) {
              statusMessage = IntifaceLocalizations.serverNotRunning;
              statusIcon = Icons.bedtime;
              buttonAction = () async {
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
                if (!context.mounted) return;
                engineControlBloc.add(
                  EngineControlEventStart(
                    options: await BlocProvider.of<IntifaceConfigurationCubit>(
                      context,
                      listen: false,
                    ).getEngineOptions(),
                  ),
                );
              };
            } else if (state is EngineStartingState) {
              statusIcon = Icons.start;
              statusMessage = IntifaceLocalizations.serverStarting;
              buttonAction = null;
            }

            IconButton controlButton;

            if (isDesktop() &&
                configCubit.useProcessEngine &&
                !IntifacePaths.engineFile.existsSync()) {
              controlButton = IconButton(
                key: DocsScreenshotKeys.engineControlButton,
                style: IconButton.styleFrom(
                  foregroundColor: colors.onPrimary,
                  backgroundColor: colors.primary,
                  disabledBackgroundColor: colors.onSurface.withValues(
                    alpha: 0.12,
                  ),
                  hoverColor: colors.onPrimary.withValues(alpha: 0.08),
                  focusColor: colors.onPrimary.withValues(alpha: 0.12),
                  highlightColor: colors.onPrimary.withValues(alpha: 0.12),
                ),
                iconSize: 90,
                onPressed: null,
                tooltip: IntifaceLocalizations.engineFileNotFound,
                icon: const Icon(Icons.error),
              );
            } else {
              controlButton = IconButton(
                key: DocsScreenshotKeys.engineControlButton,
                style: IconButton.styleFrom(
                  foregroundColor: colors.onPrimary,
                  backgroundColor: colors.primary,
                  disabledBackgroundColor: colors.onSurface.withValues(
                    alpha: 0.12,
                  ),
                  hoverColor: colors.onPrimary.withValues(alpha: 0.08),
                  focusColor: colors.onPrimary.withValues(alpha: 0.12),
                  highlightColor: colors.onPrimary.withValues(alpha: 0.12),
                ),
                iconSize: 90,
                onPressed: buttonAction,
                tooltip: state is EngineStoppedState
                    ? IntifaceLocalizations.startServer
                    : IntifaceLocalizations.stopServer,
                icon: Icon(
                  state is EngineStoppedState ? Icons.play_arrow : Icons.stop,
                ),
              );
            }

            var engineStatus = IntifaceLocalizations.engineStatusUnknown;
            switch (configCubit.appMode) {
              case AppMode.engine:
                if (state is ClientConnectedState) {
                  engineStatus = "${state.clientName} ${IntifaceLocalizations.clientConnected}";
                } else if (state is EngineStartedState ||
                    state is EngineServerCreatedState ||
                    state is ClientDisconnectedState) {
                  engineStatus = IntifaceLocalizations.engineRunningWaitingClient;
                } else if (state is EngineStartingState) {
                  engineStatus = IntifaceLocalizations.engineStarting;
                } else if (state is EngineStoppedState) {
                  engineStatus = IntifaceLocalizations.engineNotRunning;
                } else {
                  logWarning("Engine Status $state unknown");
                }
              case AppMode.repeater:
                {
                  if (state is EngineStartedState ||
                      state is EngineServerCreatedState ||
                      state is ClientDisconnectedState) {
                    engineStatus = IntifaceLocalizations.repeaterRunning;
                  } else if (state is EngineStoppedState) {
                    engineStatus = IntifaceLocalizations.repeaterNotRunning;
                  } else if (state is EngineStartingState) {
                    engineStatus = IntifaceLocalizations.repeaterStarting;
                  }
                }
              case AppMode.restApi:
                {
                  if (state is EngineStartedState ||
                      state is EngineServerCreatedState ||
                      state is ClientDisconnectedState) {
                    engineStatus = IntifaceLocalizations.restApiRunning;
                  } else if (state is EngineStoppedState) {
                    engineStatus = IntifaceLocalizations.restApiNotRunning;
                  } else if (state is EngineStartingState) {
                    engineStatus = IntifaceLocalizations.restApiStarting;
                  }
                }
            }

            List<Widget> columnWidgets = [
              const Text(
                IntifaceLocalizations.status,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(engineStatus),
            ];

            if (configCubit.appMode == AppMode.engine) {
              columnWidgets.addAll([
                const Text(
                  IntifaceLocalizations.serverAddress,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                BlocBuilder<
                  IntifaceConfigurationCubit,
                  IntifaceConfigurationState
                >(
                  bloc: configCubit,
                  buildWhen: (previous, current) =>
                      current is WebsocketServerAllInterfacesState ||
                      current is WebsocketServerPortState,
                  builder: (context, state) => Text(
                    "ws://${configCubit.websocketServerAllInterfaces ? (networkCubit.ip ?? "0.0.0.0") : "localhost"}:${configCubit.websocketServerPort}",
                  ),
                ),
              ]);
            }

            return Row(
              key: DocsScreenshotKeys.engineControlPanel,
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: controlButton,
                ),
                Expanded(
                  child: Column(
                    key: DocsScreenshotKeys.engineControlInfo,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: columnWidgets,
                  ),
                ),
                KeyedSubtree(
                  key: DocsScreenshotKeys.engineAppStatus,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BlocBuilder(
                        bloc: BlocProvider.of<ErrorNotifierCubit>(context),
                        builder: (context, ErrorNotifierState state) {
                          return Visibility(
                            visible: state is ErrorNotifierTriggerState
                                ? true
                                : false,
                            child: TextButton.icon(
                              label: const Text(IntifaceLocalizations.error),
                              onPressed: () => navCubit.goLogs(),
                              icon: const Icon(Icons.warning),
                              style: ButtonStyle(
                                foregroundColor:
                                    WidgetStateProperty.resolveWith(
                                      (s) => Colors.red,
                                    ),
                              ),
                            ),
                          );
                        },
                      ),
                      Visibility(
                        visible:
                            isDesktop() &&
                            canShowUpdate() &&
                            configCubit.currentAppVersion !=
                                configCubit.latestAppVersion,
                        child: TextButton.icon(
                          label: const Text(IntifaceLocalizations.update),
                          onPressed: () => navCubit.goSettings(),
                          icon: const Icon(Icons.update, color: Colors.green),
                          style: ButtonStyle(
                            foregroundColor: WidgetStateProperty.resolveWith(
                              (s) => Colors.green,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: false,
                        child: TextButton.icon(
                          onPressed: () => navCubit.goNews(),
                          icon: const Icon(Icons.newspaper),
                          label: const Text(IntifaceLocalizations.news),
                          style: ButtonStyle(
                            foregroundColor: WidgetStateProperty.resolveWith(
                              (s) => Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Tooltip(
                  key: DocsScreenshotKeys.engineConnectionIcon,
                  message: statusMessage,
                  child: Icon(statusIcon, size: 70),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
