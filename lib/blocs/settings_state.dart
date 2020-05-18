import 'package:garden_madam/mqtt.dart';
import 'package:mqtt_client/mqtt_client.dart';

abstract class SettingsState {
  const SettingsState();
}

class SettingsLoading extends SettingsState {}

class InvalidMqttSettings extends SettingsState {}

class SettingsError extends SettingsState {}

class SettingsLoaded extends SettingsState {
  MqttConfig mqttConfig;
  MqttClient mqttClient;
  List<ButlerConfig> butlerConfigs;

  SettingsLoaded({this.mqttConfig, this.butlerConfigs, this.mqttClient});
}

class ButlerConfig {
  String id;
  List<PinConfig> pinConfigs;

  ButlerConfig(this.id, this.pinConfigs);
}

class PinConfig {
  int pin;
  String name;

  PinConfig(this.pin, this.name);
}
