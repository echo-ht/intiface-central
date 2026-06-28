import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intiface_central/bloc/configuration/intiface_configuration_cubit.dart';
import 'package:intiface_central/bloc/util/navigation_cubit.dart';
import 'package:intiface_central/util/intiface_util.dart';
import 'package:intiface_central/util/intiface_localizations.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';

class SettingsAppWidget extends AbstractSettingsSection {
  final IntifaceConfigurationCubit cubit;

  const SettingsAppWidget({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    const themeModeLabels = {
      "system": IntifaceLocalizations.themeSystem,
      "light": IntifaceLocalizations.themeLight,
      "dark": IntifaceLocalizations.themeDark,
    };
    var appSettingsTiles = <AbstractSettingsTile>[
      SettingsTile.navigation(
        title: _settingsText(IntifaceLocalizations.theme),
        value: _settingsText(
          themeModeLabels[cubit.themeModeSetting] ?? IntifaceLocalizations.themeSystem,
        ),
        onPressed: (context) {
          showDialog<String>(
            context: context,
            builder: (context) => SimpleDialog(
              title: Text(IntifaceLocalizations.theme),
              children: [
                RadioGroup<String>(
                  groupValue: cubit.themeModeSetting,
                  onChanged: (value) {
                    if (value != null) {
                      cubit.themeModeSetting = value;
                    }
                    Navigator.pop(context);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: themeModeLabels.entries
                        .map(
                          (e) => RadioListTile<String>(
                            title: Text(e.value),
                            value: e.key,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      SettingsTile.switchTile(
        initialValue: cubit.useSideNavigationBar,
        onToggle: (value) => cubit.useSideNavigationBar = value,
        title: _settingsText(IntifaceLocalizations.sideNavigationBar),
      ),
      SettingsTile.switchTile(
        initialValue: cubit.checkForUpdateOnStart,
        onToggle: (value) => cubit.checkForUpdateOnStart = value,
        title: _settingsText(
          IntifaceLocalizations.checkUpdatesOnLaunch,
        ),
      ),
      SettingsTile.switchTile(
        initialValue: cubit.crashReporting,
        onToggle: cubit.canUseCrashReporting
            ? ((value) => cubit.crashReporting = value)
            : null,
        title: _settingsText(IntifaceLocalizations.crashReporting),
      ),
      SettingsTile.navigation(
        title: _settingsText(IntifaceLocalizations.sendLogsToDevelopers),
        onPressed: (context) =>
            BlocProvider.of<NavigationCubit>(context).goSendLogs(),
      ),
    ];

    if (isDesktop()) {
      appSettingsTiles.insert(
        2,
        SettingsTile.switchTile(
          initialValue: cubit.restoreWindowLocation,
          onToggle: (value) => cubit.restoreWindowLocation = value,
          title: _settingsText(IntifaceLocalizations.restoreWindowLocation),
        ),
      );

      appSettingsTiles.insert(
        3,
        SettingsTile.switchTile(
          initialValue: cubit.useDiscordRichPresence,
          onToggle: (value) => cubit.useDiscordRichPresence = value,
          title: _settingsText(IntifaceLocalizations.enableDiscordRichPresence),
        ),
      );
    }

    if (supportsTray()) {
      const trayIconModeLabels = {
        "none": IntifaceLocalizations.trayIconNone,
        "both": IntifaceLocalizations.trayIconTaskbar,
        "tray_only": IntifaceLocalizations.trayIconOnly,
      };

      appSettingsTiles.insert(
        isDesktop() ? 4 : 2,
        SettingsTile.navigation(
          title: _settingsText(IntifaceLocalizations.systemTrayIcon),
          value: _settingsText(
            trayIconModeLabels[cubit.trayIconMode] ?? IntifaceLocalizations.trayIconTaskbar,
          ),
          onPressed: (context) {
            showDialog<String>(
              context: context,
              builder: (context) => SimpleDialog(
                title: Text(IntifaceLocalizations.systemTrayIcon),
                children: [
                  RadioGroup<String>(
                    groupValue: cubit.trayIconMode,
                    onChanged: (value) {
                      if (value != null) {
                        cubit.trayIconMode = value;
                      }
                      Navigator.pop(context);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: trayIconModeLabels.entries
                          .map(
                            (e) => RadioListTile<String>(
                              title: Text(e.value),
                              value: e.key,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    return SettingsSection(
      title: _settingsText(IntifaceLocalizations.appSettings),
      tiles: appSettingsTiles,
    );
  }
}

const _settingsTextStyle = TextStyle(fontFamily: 'Roboto');

Text _settingsText(String text) {
  return Text(text, style: _settingsTextStyle);
}
