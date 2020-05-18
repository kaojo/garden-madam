import 'dart:async';
import 'dart:developer';

import 'package:garden_madam/blocs/blocs.dart';
import 'package:garden_madam/blocs/settings_state.dart';
import 'package:garden_madam/mqtt.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SettingsRepository {
  MqttConfig _mqttConfig;
  MqttClient _mqttClient;
  Uuid uuid = Uuid();

  Future<SettingsEvent> init() {
    return _readMqttSettings().then((value) {
      this._mqttClient = _getMqttClient(_mqttConfig);
      return this
          ._mqttClient
          .connect(_mqttConfig.username, _mqttConfig.password);
    }).then((value) {
      if (value.state == MqttConnectionState.connected ||
          value.state == MqttConnectionState.connecting) {
        return SettingsLoadedEvent();
      }
      return InvalidMqttSettingsEvent();
    }).catchError((error) {
      if (error == "INVALID_MQTT_CONFIG") {
        return InvalidMqttSettingsEvent();
      }
      log(error.stackTrace.toString());
      return SettingsLoadErrorEvent();
    });
  }

  Future<MqttConfig> _readMqttSettings() async {
    await mqttConfig();

    bool hasConfig =
        !_isEmpty(this._mqttConfig.hostname) && this._mqttConfig.port != null;
    if (!hasConfig) {
      throw ("INVALID_MQTT_CONFIG");
    }
    return this._mqttConfig;
  }

  bool _isEmpty(String string) {
    return string == null || string.isEmpty;
  }

  SettingsState reload() {
    this._mqttClient = _getMqttClient(_mqttConfig);
    this._mqttClient.connect(_mqttConfig.username, _mqttConfig.password);
    return SettingsLoaded(mqttConfig: _mqttConfig, mqttClient: _mqttClient);
  }

  SettingsState settingsState() {
    return SettingsLoaded(mqttConfig: _mqttConfig, mqttClient: _mqttClient);
  }

  MqttClient _getMqttClient(MqttConfig mqttConfig) {
    var mqttClient = MqttClient.withPort(
        mqttConfig.hostname, mqttConfig.client_id, mqttConfig.port);
    mqttClient.secure = true;
    mqttClient.onConnected = _onConnected;
    mqttClient.onSubscribed = _onSubscribed;
    //mqttClient.logging(on: true);

    return mqttClient;
  }

  void _onConnected() {
    log("connected successful");
  }

  void _onSubscribed(String topic) {
    log('Subscription confirmed for topic $topic');
  }

  Future<MqttConfig> mqttConfig() async {
    final prefs = await SharedPreferences.getInstance();

    if (_mqttConfig == null) {
      this._mqttConfig = MqttConfig(uuid.v1());
    }

    var mqttHost = prefs.getString("mqttHost");
    var mqttPort = prefs.getInt("mqttPort");
    var mqttUsername = prefs.getString("mqttUsername");
    var mqttPassword = prefs.getString("mqttPassword");

    this._mqttConfig.hostname = mqttHost;
    this._mqttConfig.port = mqttPort;
    this._mqttConfig.username = mqttUsername;
    this._mqttConfig.password = mqttPassword;

    return this._mqttConfig;
  }

  Future<void> save(
      String hostname, int port, String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("mqttHost", hostname);
    await prefs.setInt("mqttPort", port);
    await prefs.setString("mqttUsername", username);
    await prefs.setString("mqttPassword", password);
  }
}
