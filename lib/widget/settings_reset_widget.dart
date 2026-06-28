import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intiface_central/bloc/util/app_reset_cubit.dart';
import 'package:intiface_central/bloc/configuration/intiface_configuration_cubit.dart';
import 'package:intiface_central/util/intiface_util.dart';
import 'package:intiface_central/util/intiface_localizations.dart';
import 'package:loggy/loggy.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';

class SettingsResetWidget extends AbstractSettingsSection with UiLoggy {
  final IntifaceConfigurationCubit cubit;
  final bool engineIsRunning;

  SettingsResetWidget({
    super.key,
    required this.cubit,
    required this.engineIsRunning,
  });

  void _showResetDialog(
    BuildContext context, {
    required String title,
    required String description,
    required Future<void> Function(
      NavigatorState navigator,
      AppResetCubit resetCubit,
    )
    onConfirm,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(description),
                Text(IntifaceLocalizations.wouldYouLikeToContinue),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(IntifaceLocalizations.ok),
              onPressed: () async {
                var navigator = Navigator.of(context);
                var resetCubit = BlocProvider.of<AppResetCubit>(context);
                await onConfirm(navigator, resetCubit);
              },
            ),
            TextButton(
              child: Text(IntifaceLocalizations.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: _settingsText(IntifaceLocalizations.resetApplication),
      tiles: [
        SettingsTile.navigation(
          onPressed: !engineIsRunning
              ? (context) {
                  _showResetDialog(
                    context,
                    title: IntifaceLocalizations.resetUserDeviceConfigTitle,
                    description:
                        IntifaceLocalizations.resetUserDeviceConfigDesc,
                    onConfirm: (navigator, resetCubit) async {
                      logWarning("Running user device configuration reset");
                      if (await IntifacePaths.userDeviceConfigFile.exists()) {
                        await IntifacePaths.userDeviceConfigFile.delete();
                      }
                      logWarning("User device configuration reset finished");
                      navigator.pop();
                      resetCubit.reset();
                    },
                  );
                }
              : null,
          title: _settingsText(IntifaceLocalizations.resetUserDeviceConfig),
        ),
        SettingsTile.navigation(
          onPressed: !engineIsRunning
              ? (context) {
                  _showResetDialog(
                    context,
                    title: IntifaceLocalizations.resetAppToDefaultsTitle,
                    description:
                        IntifaceLocalizations.resetAppToDefaultsDesc,
                    onConfirm: (navigator, resetCubit) async {
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
                      navigator.pop();
                      resetCubit.reset();
                    },
                  );
                }
              : null,
          title: _settingsText(IntifaceLocalizations.resetAppConfig),
        ),
      ],
    );
  }
}

const _settingsTextStyle = TextStyle(fontFamily: 'Roboto');

Text _settingsText(String text) {
  return Text(text, style: _settingsTextStyle);
}
