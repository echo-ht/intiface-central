import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intiface_central/bloc/configuration/intiface_configuration_cubit.dart';
import 'package:intiface_central/bloc/engine/engine_control_bloc.dart';
import 'package:intiface_central/util/docs_screenshot_keys.dart';
import 'package:intiface_central/util/intiface_localizations.dart';
import 'package:intiface_central/theme/cyberpunk.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';

class RepeaterConfigWidget extends StatefulWidget {
  const RepeaterConfigWidget({super.key});

  @override
  State<RepeaterConfigWidget> createState() => _RepeaterConfigWidgetState();
}

class _RepeaterConfigWidgetState extends State<RepeaterConfigWidget> {
  late TextEditingController _repeaterAddressController;
  late TextEditingController _repeaterPortController;

  @override
  void initState() {
    super.initState();
    _repeaterAddressController = TextEditingController();
    _repeaterPortController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var configCubit = BlocProvider.of<IntifaceConfigurationCubit>(context);
    _repeaterAddressController.text = configCubit.repeaterRemoteAddress;
    _repeaterPortController.text = configCubit.repeaterLocalPort.toString();
  }

  @override
  void dispose() {
    _repeaterAddressController.dispose();
    _repeaterPortController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EngineControlBloc, EngineControlState>(
        buildWhen: ((previous, current) =>
            current is EngineStartedState || current is EngineStoppedState),
        builder: (context, engineState) {
          return BlocBuilder<
            IntifaceConfigurationCubit,
            IntifaceConfigurationState
          >(
            buildWhen: (previousState, currentState) =>
                currentState is RepeaterLocalPortState ||
                currentState is RepeaterRemoteAddressState,
            builder: (context, state) {
              var cubit = BlocProvider.of<IntifaceConfigurationCubit>(context);
              var engineIsRunning = BlocProvider.of<EngineControlBloc>(
                context,
              ).isRunning;
              List<AbstractSettingsSection> tiles = [
                SettingsSection(
                  title: _settingsText(IntifaceLocalizations.repeaterSettings),
                  tiles: [
                    SettingsTile.navigation(
                      enabled: !engineIsRunning,
                      title: _settingsText(IntifaceLocalizations.repeaterPort),
                      value: _settingsText(cubit.repeaterLocalPort.toString()),
                      onPressed: (context) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(IntifaceLocalizations.localPort),
                            content: TextField(
                              keyboardType: TextInputType.number,
                              controller: _repeaterPortController,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onSubmitted: (value) {
                                var newPort = int.tryParse(value);
                                if (newPort != null &&
                                    newPort > 1024 &&
                                    newPort < 65536) {
                                  cubit.repeaterLocalPort = newPort;
                                }
                                Navigator.pop(context);
                              },
                              decoration: InputDecoration(
                                hintText: IntifaceLocalizations.localPort,
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, 'Cancel'),
                                child: Text(IntifaceLocalizations.cancel),
                              ),
                              TextButton(
                                onPressed: () {
                                  var newPort = int.tryParse(
                                    _repeaterPortController.text,
                                  );
                                  if (newPort != null &&
                                      newPort > 1024 &&
                                      newPort < 65536) {
                                    cubit.repeaterLocalPort = newPort;
                                  }
                                  Navigator.pop(context);
                                },
                                child: Text(IntifaceLocalizations.ok),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    SettingsTile.navigation(
                      enabled: !engineIsRunning,
                      title: _settingsText(IntifaceLocalizations.remoteServerAddress),
                      value: _settingsText(cubit.repeaterRemoteAddress),
                      onPressed: (context) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(IntifaceLocalizations.remoteServerAddress),
                            content: TextField(
                              controller: _repeaterAddressController,
                              onSubmitted: (value) {
                                cubit.repeaterRemoteAddress = value;
                                Navigator.pop(context);
                              },
                              decoration: InputDecoration(
                                hintText: IntifaceLocalizations.remoteServerAddress,
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, 'Cancel'),
                                child: Text(IntifaceLocalizations.cancel),
                              ),
                              TextButton(
                                onPressed: () {
                                  cubit.repeaterRemoteAddress =
                                      _repeaterAddressController.text;
                                  Navigator.pop(context);
                                },
                                child: Text(IntifaceLocalizations.ok),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ];
              return SettingsList(
                key: DocsScreenshotKeys.appModeSettingsBody,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                darkTheme: cyberpunkSettingsTheme,
                sections: tiles,
              );
            },
          );
        },
      );
  }
}

const _settingsTextStyle = TextStyle();

Text _settingsText(String text) {
  return Text(text, style: _settingsTextStyle);
}
