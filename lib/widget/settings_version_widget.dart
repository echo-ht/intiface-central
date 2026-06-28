import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intiface_central/bloc/update/github_update_provider.dart';
import 'package:intiface_central/bloc/configuration/intiface_configuration_cubit.dart';
import 'package:intiface_central/util/intiface_util.dart';
import 'package:intiface_central/util/intiface_localizations.dart';
import 'package:intiface_central/bloc/update/update_bloc.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SettingsVersionWidget extends AbstractSettingsSection {
  final IntifaceConfigurationCubit cubit;
  final bool engineIsRunning;

  const SettingsVersionWidget({
    super.key,
    required this.cubit,
    required this.engineIsRunning,
  });

  Widget _buildVersionRow(String label, String version, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: colorScheme.onSurface)),
          Text(version, style: TextStyle(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  List<Widget> _buildUpdateLinks(BuildContext context) {
    final links = <Widget>[];
    if (!isDesktop() ||
        !canShowUpdate() ||
        cubit.currentAppVersion == cubit.latestAppVersion) {
      return links;
    }

    if (Platform.isWindows) {
      links.add(
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: InkWell(
            onTap: () {
              showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  var updater = IntifaceCentralDesktopUpdater();
                  updater.downloadUpdate();
                  return AlertDialog(
                    title: Text(IntifaceLocalizations.downloadingUpdate),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          SpinKitFadingCircle(color: Colors.black, size: 50.0),
                          Text(
                            IntifaceLocalizations.downloadingUpdateMsg,
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text(IntifaceLocalizations.cancel),
                        onPressed: () {
                          updater.stopExit();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: Text(
              IntifaceLocalizations.desktopUpdateAvailable(cubit.latestAppVersion),
              style: const TextStyle(color: Colors.green),
            ),
          ),
        ),
      );
      links.add(
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: InkWell(
            onTap: () async {
              const url =
                  "https://github.com/intiface/intiface-central/releases";
              if (await canLaunchUrlString(url)) {
                await launchUrlString(url);
              }
            },
            child: const Text(
              IntifaceLocalizations.manualDownloadHint,
              style: TextStyle(color: Colors.green),
            ),
          ),
        ),
      );
    } else {
      links.add(
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: InkWell(
            onTap: () async {
              const url =
                  "https://github.com/intiface/intiface-central/releases";
              if (await canLaunchUrlString(url)) {
                await launchUrlString(url);
              }
            },
            child: Text(
              IntifaceLocalizations.nonWindowsUpdateAvailable(cubit.latestAppVersion),
              style: const TextStyle(color: Colors.green),
            ),
          ),
        ),
      );
    }

    return links;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              IntifaceLocalizations.versionsAndUpdates,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildVersionRow(IntifaceLocalizations.appVersion, cubit.currentAppVersion, context),
            _buildVersionRow(
              IntifaceLocalizations.deviceConfigVersion,
              cubit.currentDeviceConfigVersion,
              context,
            ),
            ..._buildUpdateLinks(context),
            const Divider(),
            Center(
              child: OutlinedButton(
                onPressed: !engineIsRunning
                    ? () => BlocProvider.of<UpdateBloc>(context).add(RunUpdate())
                    : null,
                child: isDesktop()
                    ? Text(IntifaceLocalizations.checkForAppAndConfigUpdates)
                    : Text(IntifaceLocalizations.checkForConfigUpdates),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
