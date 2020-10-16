import 'dart:collection';

import 'package:garden_madam/models/mqtt.dart';
import 'package:mqtt_client/mqtt_client.dart';

abstract class SettingsState {
  const SettingsState();
}

class SettingsLoading extends SettingsState {}

class InvalidMqttSettings extends SettingsState {}

class SettingsError extends SettingsState {
  final String errorMessage;

  const SettingsError(this.errorMessage);
}

class SettingsLoaded extends SettingsState {
  MqttConfig mqttConfig;
  MqttClient mqttClient;
  List<ButlerConfig> butlerConfigs;

  SettingsLoaded({this.mqttConfig, this.butlerConfigs, this.mqttClient});
}

class ButlerConfig {
  String id;
  String name;
  List<PinConfig> _pinConfigs;

  ButlerConfig({this.id, this.name, pinConfigs})
      : this._pinConfigs = pinConfigs;

  UnmodifiableListView<PinConfig> get pinConfigs => _pinConfigs != null
      ? UnmodifiableListView(_pinConfigs)
      : UnmodifiableListView([]);

  @override
  String toString() {
    return '{"id": "$id", "name": "$name", "pinConfigs": $_pinConfigs}';
  }
}

class PinConfig {
  int number;
  String name;

  PinConfig({this.number, this.name});

  @override
  String toString() {
    return '{"number": $number, "name": "$name"}';
  }
}
