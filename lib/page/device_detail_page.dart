import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_multi_slider/flutter_multi_slider.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:intiface_central/bloc/device/device_cubit.dart';
import 'package:intiface_central/bloc/device/device_input_cubit.dart';
import 'package:intiface_central/bloc/device/device_output_cubit.dart';
import 'package:intiface_central/bloc/device/device_manager_bloc.dart';
import 'package:intiface_central/bloc/device_configuration/user_device_configuration_cubit.dart';
import 'package:intiface_central/bloc/engine/engine_control_bloc.dart';
import 'package:intiface_central/src/rust/api/device_config.dart';
import 'package:intiface_central/src/rust/api/enums.dart';
import 'package:intiface_central/util/docs_screenshot_keys.dart';
import 'package:intiface_central/util/intiface_localizations.dart';
import 'package:intiface_central/theme/cyberpunk.dart';
import 'package:intiface_central/widget/expandable_card_widget.dart';
import 'package:intiface_central/widget/observation_chart_widget.dart';
import 'package:loggy/loggy.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

const _settingsTextStyle = TextStyle();

Text _settingsText(String text) {
  return Text(text, style: _settingsTextStyle);
}

class DeviceDetailPage extends StatelessWidget {
  final String _address;
  final String _protocol;
  final String? _identifier;
  final VoidCallback onBack;

  DeviceDetailPage({
    super.key,
    required ExposedUserDeviceIdentifier identifier,
    required this.onBack,
  }) : _address = identifier.address,
       _protocol = identifier.protocol,
       _identifier = identifier.identifier;

  MapEntry<ExposedUserDeviceIdentifier, ExposedServerDeviceDefinition>?
  _findConfig(UserDeviceConfigurationCubit cubit) {
    for (final entry in cubit.configs.entries) {
      if (entry.key.address == _address &&
          entry.key.protocol == _protocol &&
          entry.key.identifier == _identifier) {
        return entry;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EngineControlBloc, EngineControlState>(
      buildWhen: (previous, current) =>
          current is EngineStartedState ||
          current is EngineStoppedState ||
          current is DeviceConnectedState ||
          current is DeviceDisconnectedState,
      builder: (context, engineState) {
        return BlocBuilder<DeviceManagerBloc, DeviceManagerState>(
          builder: (context, deviceManagerState) {
            return BlocBuilder<
              UserDeviceConfigurationCubit,
              UserDeviceConfigurationState
            >(
              builder: (context, userConfigState) {
                final userDeviceConfigCubit =
                    BlocProvider.of<UserDeviceConfigurationCubit>(context);
                final configEntry = _findConfig(userDeviceConfigCubit);
                if (configEntry == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) => onBack());
                  return const SizedBox.shrink();
                }
                final currentIdentifier = configEntry.key;
                final config = configEntry.value;

                final engineRunning = BlocProvider.of<EngineControlBloc>(
                  context,
                ).isRunning;
                final displayName = config.displayName ?? config.name;

                final deviceBloc = BlocProvider.of<DeviceManagerBloc>(context);
                DeviceCubit? deviceCubit;
                try {
                  deviceCubit = deviceBloc.devices.firstWhere(
                    (d) => d.device!.index == config.index,
                  );
                } catch (_) {}
                final isConnected =
                    deviceCubit != null &&
                    deviceCubit.state is DeviceStateOnline;

                return Expanded(
                  child: Column(
                    children: [
                      _DetailHeader(title: displayName, onBack: onBack),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _DeviceInfoSection(
                                config: config,
                                identifier: currentIdentifier,
                              ),
                              const Divider(),
                              _DeviceConfigSection(
                                identifier: currentIdentifier,
                                config: config,
                                engineRunning: engineRunning,
                                userDeviceConfigCubit: userDeviceConfigCubit,
                              ),
                              const Divider(),
                              if (isConnected)
                                DeviceControlsSection(deviceCubit: deviceCubit),
                              _FeatureConfigSection(
                                identifier: currentIdentifier,
                                definition: config,
                                engineRunning: engineRunning,
                              ),
                              _ForgetDeviceButton(
                                enabled: !engineRunning,
                                onPressed: () async {
                                  await userDeviceConfigCubit
                                      .removeDeviceConfig(currentIdentifier);
                                  onBack();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _DetailHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _DetailHeader({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack,
            tooltip: IntifaceLocalizations.backToDeviceList,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceInfoSection extends StatelessWidget {
  final ExposedServerDeviceDefinition config;
  final ExposedUserDeviceIdentifier identifier;

  const _DeviceInfoSection({required this.config, required this.identifier});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      key: DocsScreenshotKeys.deviceDetailInfo,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            IntifaceLocalizations.deviceInfo,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          _infoRow(context, IntifaceLocalizations.hardwareName, config.name),
          if (config.displayName != null)
            _infoRow(context, IntifaceLocalizations.displayName, config.displayName!),
          _infoRow(context, IntifaceLocalizations.protocol, identifier.protocol),
          _infoRow(context, IntifaceLocalizations.address, identifier.address),
          _infoRow(context, IntifaceLocalizations.index, config.index.toString()),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _DeviceConfigSection extends StatelessWidget {
  final ExposedUserDeviceIdentifier identifier;
  final ExposedServerDeviceDefinition config;
  final bool engineRunning;
  final UserDeviceConfigurationCubit userDeviceConfigCubit;

  const _DeviceConfigSection({
    required this.identifier,
    required this.config,
    required this.engineRunning,
    required this.userDeviceConfigCubit,
  });

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: DocsScreenshotKeys.deviceDetailConfiguration,
      child: SettingsList(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        darkTheme: cyberpunkSettingsTheme,
        sections: [
          SettingsSection(
            title: _settingsText(IntifaceLocalizations.configuration),
            tiles: [
              SettingsTile.navigation(
                enabled: !engineRunning,
                title: _settingsText(IntifaceLocalizations.displayName),
                value: _settingsText(config.displayName ?? ''),
                onPressed: (context) => _showDisplayNameDialog(context),
              ),
              SettingsTile.navigation(
                enabled: !engineRunning,
                title: _settingsText(IntifaceLocalizations.messageGap),
                value: _settingsText(
                  config.messageGapMs?.toString() ?? IntifaceLocalizations.default_,
                ),
                onPressed: (context) => _showMessageGapDialog(context),
              ),
              SettingsTile.switchTile(
                enabled: !engineRunning,
                initialValue: !config.deny,
                onToggle: (value) async {
                  await userDeviceConfigCubit.updateDeviceDeny(
                    identifier,
                    config,
                    !value,
                  );
                },
                title: _settingsText(IntifaceLocalizations.connectToThisDevice),
              ),
              SettingsTile.switchTile(
                enabled: !engineRunning,
                initialValue: config.allow,
                onToggle: (value) async {
                  await userDeviceConfigCubit.updateDeviceAllow(
                    identifier,
                    config,
                    value,
                  );
                },
                title: _settingsText(IntifaceLocalizations.onlyConnectToThisDevice),
                description: _settingsText(
                  IntifaceLocalizations.onlyConnectDescription,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDisplayNameDialog(BuildContext context) {
    final controller = TextEditingController(text: config.displayName ?? '');
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(IntifaceLocalizations.displayName),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: IntifaceLocalizations.displayNameEntry),
          onSubmitted: (value) async {
            Navigator.pop(dialogContext);
            await userDeviceConfigCubit.updateDisplayName(
              identifier,
              config,
              value,
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await userDeviceConfigCubit.updateDisplayName(
                identifier,
                config,
                controller.text,
              );
            },
            child: Text(IntifaceLocalizations.ok),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(IntifaceLocalizations.cancel),
          ),
        ],
      ),
    );
  }

  void _showMessageGapDialog(BuildContext context) {
    final controller = TextEditingController(
      text: config.messageGapMs?.toString() ?? '',
    );
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(IntifaceLocalizations.messageGap),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: IntifaceLocalizations.leaveEmptyForDefault,
          ),
          onSubmitted: (value) async {
            Navigator.pop(dialogContext);
            await userDeviceConfigCubit.updateMessageGapMs(
              identifier,
              config,
              int.tryParse(value),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await userDeviceConfigCubit.updateMessageGapMs(
                identifier,
                config,
                int.tryParse(controller.text),
              );
            },
            child: Text(IntifaceLocalizations.ok),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await userDeviceConfigCubit.updateMessageGapMs(
                identifier,
                config,
                null,
              );
            },
            child: Text(IntifaceLocalizations.clear),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(IntifaceLocalizations.cancel),
          ),
        ],
      ),
    );
  }
}

class DeviceControlsSection extends StatelessWidget {
  final DeviceCubit deviceCubit;

  const DeviceControlsSection({super.key, required this.deviceCubit});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final List<Widget> controls = [];
    final chartedFeatures = <int>{};

    for (var i = 0; i < deviceCubit.outputs.length; i++) {
      final output = deviceCubit.outputs[i];
      final featureIdx = output.feature.feature.featureIndex;
      final isLastOutputForFeature = !deviceCubit.outputs
          .skip(i + 1)
          .any((o) => o.feature.feature.featureIndex == featureIdx);
      final observationCubit =
          (isLastOutputForFeature && chartedFeatures.add(featureIdx))
          ? deviceCubit.observations[featureIdx]
          : null;

      if (output is ValueOutputCubit) {
        var range = output.feature.feature.output![output.type]!.value!;
        controls.addAll([
          ListTile(
            title: Text(output.type.name),
            subtitle: Text(
              '描述: ${output.feature.feature.featureDescription} - '
              '步数范围: $range',
            ),
          ),
          BlocBuilder<DeviceOutputCubit, DeviceOutputState>(
            bloc: output,
            buildWhen: (previous, current) =>
                current is DeviceOutputStateUpdate,
            builder: (context, state) => Slider(
              min: range[0].toDouble(),
              max: range[1].toDouble(),
              value: output.currentValue.floorToDouble(),
              divisions: (range[0].abs() + range[1].abs()),
              onChanged: (value) async {
                output.setValue(value.ceil());
              },
            ),
          ),
          if (observationCubit != null)
            ObservationChartWidget(observationCubit: observationCubit),
        ]);
      } else if (output is PositionWithDurationOutputCubit) {
        var range = output.feature.feature.output![output.type]!.value!;
        controls.addAll([
          ListTile(
            title: Text(IntifaceLocalizations.featureLinear),
            subtitle: Text(
              '描述: ${output.feature.feature.featureDescription} - '
              '步数范围: $range',
            ),
          ),
          BlocBuilder<DeviceOutputCubit, DeviceOutputState>(
            bloc: output,
            buildWhen: (previous, current) =>
                current is DeviceOutputStateUpdate,
            builder: (context, state) {
              return Column(
                children: [
                  RangeSlider(
                    max: range[1].toDouble(),
                    values: RangeValues(output.currentMin, output.currentMax),
                    divisions: range[1],
                    onChanged: (values) async {
                      output.setPosition(values.start, values.end);
                    },
                  ),
                  Slider(
                    max: 3000,
                    value: output.currentDuration.floorToDouble(),
                    onChanged: (value) async {
                      output.duration(value);
                    },
                  ),
                  TextButton(
                    child: Text(IntifaceLocalizations.toggleOscillation),
                    onPressed: () => output.toggleRunning(),
                  ),
                ],
              );
            },
          ),
          if (observationCubit != null)
            ObservationChartWidget(observationCubit: observationCubit),
        ]);
      }
    }

    for (var input in deviceCubit.inputs) {
      if (input is InputReadBloc) {
        controls.addAll([
          ListTile(
            title: Text(input.inputType.name),
            subtitle: Text(
              '描述: ${input.descriptor} - '
              '传感器范围: ${input.sensorRange}',
            ),
          ),
          BlocBuilder<DeviceInputBloc, DeviceInputState>(
            bloc: input,
            buildWhen: (previous, current) => current is DeviceInputStateUpdate,
            builder: (context, state) {
              if (input.inputType.name == InputType.battery.name) {
                double percentage = input.currentData / 100.0;
                return LinearPercentIndicator(
                  percent: percentage,
                  animation: true,
                  lineHeight: 20.0,
                  animationDuration: 1000,
                  backgroundColor: Colors.grey,
                  progressColor: Colors.blue,
                  center: Text('${(percentage * 100).toInt()}%'),
                );
              }
              return Text('${input.currentData}');
            },
          ),
          TextButton(
            child: Text(IntifaceLocalizations.readSensor),
            onPressed: () => input.add(DeviceInputReadEvent()),
          ),
        ]);
      }
    }

    if (controls.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            IntifaceLocalizations.deviceControls,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          ...controls,
          const Divider(),
        ],
      ),
    );
  }
}

class _FeatureConfigSection extends StatelessWidget {
  final ExposedUserDeviceIdentifier identifier;
  final ExposedServerDeviceDefinition definition;
  final bool engineRunning;

  const _FeatureConfigSection({
    required this.identifier,
    required this.definition,
    required this.engineRunning,
  });

  @override
  Widget build(BuildContext context) {
    final features = definition.features;
    if (features.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 8, bottom: 4),
            child: Text(
              IntifaceLocalizations.featureConfiguration,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          for (final (index, feature) in features.indexed)
            _FeatureCard(
              key: DocsScreenshotKeys.deviceDetailFeatureConfiguration(index),
              feature: feature,
              identifier: identifier,
              definition: definition,
              engineRunning: engineRunning,
            ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final ExposedServerDeviceFeature feature;
  final ExposedUserDeviceIdentifier identifier;
  final ExposedServerDeviceDefinition definition;
  final bool engineRunning;

  const _FeatureCard({
    super.key,
    required this.feature,
    required this.identifier,
    required this.definition,
    required this.engineRunning,
  });

  void _updateOutputProps(
    BuildContext context,
    ExposedServerDeviceFeatureOutputProperties props,
  ) {
    definition.updateFeatureOutputProperties(props: props);
    final cubit = BlocProvider.of<UserDeviceConfigurationCubit>(context);
    cubit.updateDefinition(identifier, definition);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> outputWidgets = [];
    final output = feature.output;

    if (output != null) {
      final valueTypes = {
        'Vibrate': output.vibrate,
        'Rotate': output.rotate,
        'Oscillate': output.oscillate,
        'Constrict': output.constrict,
        'Temperature': output.temperature,
        'LED': output.led,
        'Spray': output.spray,
      };

      for (var entry in valueTypes.entries) {
        if (entry.value != null) {
          _buildValueSlider(context, outputWidgets, entry.key, entry.value!);
        }
      }

      if (output.position != null) {
        _buildPositionSlider(
          context,
          outputWidgets,
          'Position',
          output.position!,
        );
      }

      if (output.positionWithDuration != null) {
        _buildPositionWithDurationSlider(
          context,
          outputWidgets,
          'PositionWithDuration',
          output.positionWithDuration!,
        );
      }
    }

    if (feature.input != null) {
      outputWidgets.add(
        const ListTile(
          leading: Icon(Icons.sensors),
          title: Text(IntifaceLocalizations.sensorInput),
          subtitle: Text(IntifaceLocalizations.availableWhenConnected),
        ),
      );
    }

    return ExpandableCardWidget(
      expansionName: 'feature-config-${feature.id}',
      title: Text(
        '功能：${_featureName(feature)}',
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: Material(
          color: Colors.transparent,
          child: Column(children: outputWidgets),
        ),
      ),
    );
  }

  String _featureName(ExposedServerDeviceFeature feature) {
    if (feature.description.isNotEmpty) return feature.description;

    final output = feature.output;
    if (output != null) {
      if (output.vibrate != null) return IntifaceLocalizations.featureVibrate;
      if (output.rotate != null) return IntifaceLocalizations.featureRotate;
      if (output.oscillate != null) return IntifaceLocalizations.featureOscillate;
      if (output.constrict != null) return IntifaceLocalizations.featureConstrict;
      if (output.temperature != null) return IntifaceLocalizations.featureTemperature;
      if (output.led != null) return IntifaceLocalizations.featureLED;
      if (output.spray != null) return IntifaceLocalizations.featureSpray;
      if (output.position != null) return IntifaceLocalizations.featurePosition;
      if (output.positionWithDuration != null) return IntifaceLocalizations.featurePositionWithDuration;
    }

    final input = feature.input;
    if (input != null) {
      final types = input.inputTypes;
      if (types.isNotEmpty) {
        return switch (types.first) {
          InputType.battery => IntifaceLocalizations.inputBattery,
          InputType.rssi => IntifaceLocalizations.inputRSSI,
          InputType.button => IntifaceLocalizations.inputButton,
          InputType.pressure => IntifaceLocalizations.inputPressure,
          InputType.depth => IntifaceLocalizations.inputDepth,
          InputType.position => IntifaceLocalizations.inputPosition,
        };
      }
    }

    return IntifaceLocalizations.featureUnknown;
  }

  void _buildValueSlider(
    BuildContext context,
    List<Widget> widgets,
    String type,
    ExposedServerDeviceFeatureOutputProperties props,
  ) {
    if (props.value == null) {
      logWarning('Null prop value for $type, cannot render.');
      return;
    }
    final debouncerId = 'feature-output-${type.hashCode}-${props.hashCode}';
    widgets.addAll([
      ListTile(
        subtitle: Text(
          '$type - 步数范围 - '
          '最小: ${props.value!.base.$1} 最大: ${props.value!.base.$2} '
          '步数限制 - 最小: ${props.value!.user.$1} 最大: ${props.value!.user.$2}',
        ),
      ),
      BlocBuilder<UserDeviceConfigurationCubit, UserDeviceConfigurationState>(
        builder: (context, state) => CheckboxListTile(
          title: Text(IntifaceLocalizations.disabled),
          value: props.disabled,
          onChanged: engineRunning
              ? null
              : (value) {
                  props.disabled = value ?? false;
                  _updateOutputProps(context, props);
                },
        ),
      ),
      BlocBuilder<UserDeviceConfigurationCubit, UserDeviceConfigurationState>(
        builder: (context, state) => MultiSlider(
          max: props.value!.base.$2.toDouble(),
          values: [
            props.value!.user.$1.floorToDouble(),
            props.value!.user.$2.floorToDouble(),
          ],
          divisions: props.value!.base.$2,
          onChanged: (engineRunning || props.disabled)
              ? null
              : (value) {
                  if (value[0].toInt() == value[1].toInt()) return;
                  var v = props.value!;
                  v.user = (value[0].floor(), value[1].ceil());
                  props.value = v;
                  EasyDebounce.debounce(
                    debouncerId,
                    const Duration(milliseconds: 30),
                    () => _updateOutputProps(context, props),
                  );
                },
        ),
      ),
    ]);
  }

  void _buildPositionSlider(
    BuildContext context,
    List<Widget> widgets,
    String type,
    ExposedServerDeviceFeatureOutputProperties props,
  ) {
    if (props.position == null) {
      logWarning('Null prop position for $type, cannot render.');
      return;
    }
    final debouncerId = 'feature-output-${type.hashCode}-${props.hashCode}';
    widgets.addAll([
      ListTile(
        subtitle: Text(
          '$type - 步数范围 - '
          '最小: ${props.position!.base.$1} 最大: ${props.position!.base.$2} '
          '步数限制 - 最小: ${props.position!.user.$1} 最大: ${props.position!.user.$2}',
        ),
      ),
      BlocBuilder<UserDeviceConfigurationCubit, UserDeviceConfigurationState>(
        builder: (context, state) => CheckboxListTile(
          title: Text(IntifaceLocalizations.disabled),
          value: props.disabled,
          onChanged: engineRunning
              ? null
              : (value) {
                  props.disabled = value ?? false;
                  _updateOutputProps(context, props);
                },
        ),
      ),
      BlocBuilder<UserDeviceConfigurationCubit, UserDeviceConfigurationState>(
        builder: (context, state) => MultiSlider(
          max: props.position!.base.$2.toDouble(),
          values: [
            props.position!.user.$1.floorToDouble(),
            props.position!.user.$2.floorToDouble(),
          ],
          divisions: props.position!.base.$2,
          onChanged: (engineRunning || props.disabled)
              ? null
              : (value) {
                  if (value[0].toInt() == value[1].toInt()) return;
                  var v = props.position!;
                  v.user = (value[0].floor(), value[1].ceil());
                  props.position = v;
                  EasyDebounce.debounce(
                    debouncerId,
                    const Duration(milliseconds: 30),
                    () => _updateOutputProps(context, props),
                  );
                },
        ),
      ),
      BlocBuilder<UserDeviceConfigurationCubit, UserDeviceConfigurationState>(
        builder: (context, state) => CheckboxListTile(
          title: Text(IntifaceLocalizations.reverse),
          value: props.reversePosition,
          onChanged: (engineRunning || props.disabled)
              ? null
              : (value) {
                  props.reversePosition = value ?? false;
                  _updateOutputProps(context, props);
                },
        ),
      ),
    ]);
  }

  void _buildPositionWithDurationSlider(
    BuildContext context,
    List<Widget> widgets,
    String type,
    ExposedServerDeviceFeatureOutputProperties props,
  ) {
    if (props.position == null || props.duration == null) {
      logWarning('Null prop position/duration for $type, cannot render.');
      return;
    }
    final debouncerId = 'feature-output-${type.hashCode}-${props.hashCode}';
    widgets.addAll([
      ListTile(
        subtitle: Text(
          '$type - 位置范围 - '
          '最小: ${props.position!.base.$1} 最大: ${props.position!.base.$2} '
          '步数限制 - 最小: ${props.position!.user.$1} 最大: ${props.position!.user.$2}',
        ),
      ),
      BlocBuilder<UserDeviceConfigurationCubit, UserDeviceConfigurationState>(
        builder: (context, state) => CheckboxListTile(
          title: Text(IntifaceLocalizations.disabled),
          value: props.disabled,
          onChanged: engineRunning
              ? null
              : (value) {
                  props.disabled = value ?? false;
                  _updateOutputProps(context, props);
                },
        ),
      ),
      BlocBuilder<UserDeviceConfigurationCubit, UserDeviceConfigurationState>(
        builder: (context, state) => MultiSlider(
          max: props.position!.base.$2.toDouble(),
          values: [
            props.position!.user.$1.floorToDouble(),
            props.position!.user.$2.floorToDouble(),
          ],
          divisions: props.position!.base.$2,
          onChanged: (engineRunning || props.disabled)
              ? null
              : (value) {
                  if (value[0].toInt() == value[1].toInt()) return;
                  var v = props.position!;
                  v.user = (value[0].floor(), value[1].ceil());
                  props.position = v;
                  EasyDebounce.debounce(
                    debouncerId,
                    const Duration(milliseconds: 30),
                    () => _updateOutputProps(context, props),
                  );
                },
        ),
      ),
      BlocBuilder<UserDeviceConfigurationCubit, UserDeviceConfigurationState>(
        builder: (context, state) => CheckboxListTile(
          title: Text(IntifaceLocalizations.reverse),
          value: props.reversePosition,
          onChanged: (engineRunning || props.disabled)
              ? null
              : (value) {
                  props.reversePosition = value ?? false;
                  _updateOutputProps(context, props);
                },
        ),
      ),
    ]);
  }
}

class _ForgetDeviceButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;

  const _ForgetDeviceButton({required this.enabled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: OutlinedButton.icon(
        onPressed: enabled
            ? () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Text(IntifaceLocalizations.forgetDevice),
                    content: Text(
                      IntifaceLocalizations.forgetDeviceConfirm,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          onPressed();
                        },
                        child: Text(IntifaceLocalizations.forget),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(IntifaceLocalizations.cancel),
                      ),
                    ],
                  ),
                );
              }
            : null,
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        label: Text(IntifaceLocalizations.forgetDevice),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          foregroundColor: Colors.red,
          side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
        ),
      ),
    );
  }
}
