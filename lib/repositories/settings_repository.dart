import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:garden_madam/blocs/blocs.dart';
import 'package:garden_madam/blocs/settings_state.dart';
import 'package:garden_madam/models/mqtt.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SettingsRepository {
  MqttConfig _mqttConfig;
  MqttClient _mqttClient;
  List<ButlerConfig> _butlerConfigs = [];
  Uuid _uuid = Uuid();

  UnmodifiableListView<ButlerConfig> get butlerConfigs => _butlerConfigs != null
      ? UnmodifiableListView(_butlerConfigs)
      : UnmodifiableListView([]);

  Future<SettingsEvent> init() async {
    try {
      await _readMqttSettings();
    } catch (error, s) {
      if (error == "INVALID_MQTT_CONFIG") {
        return InvalidMqttSettingsEvent();
      }
      log(error.toString(), error: error, stackTrace: s);
      return SettingsLoadErrorEvent("Could not load mqtt settings.");
    }

    try {
      await _readButlerConfigs();
    } catch (error, s) {
      log(error.toString(), error: error, stackTrace: s);
      return SettingsLoadErrorEvent("Could not read butler config file.");
    }

    this._mqttClient = _getMqttClient(this._mqttConfig);

    try {
      await this
          ._mqttClient
          .connect(_mqttConfig.username, _mqttConfig.password);
      await Future.doWhile(() async {
        await Future.delayed(Duration(seconds: 1));
        return this._mqttClient.connectionStatus?.state !=
            MqttConnectionState.connected;
      }).timeout(Duration(seconds: 5));
      return SettingsLoadedEvent();
    } catch (error) {
      log(error.toString(), error: error);
      return SettingsLoadErrorEvent(
          "Could not establish connection to the mqtt server.");
    }
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

  Future<List<ButlerConfig>> _readButlerConfigs() async {
    final file = await _localButlerFile;
    if (!await file.exists()) {
      await file.create();
    }

    // Read the file.
    String contents = await file.readAsString();
    if (contents != null && contents.isNotEmpty) {
      List<dynamic> configs;
      try {
        configs = json.decode(contents);
      } catch (e) {
        log("Could not decode config file. Deleting", error: e);
        await file.delete();
        throw e;
      }
      var butlerConfigs = List<ButlerConfig>();
      for (var c in configs) {
        var id = c['id'];
        var name = c['name'];
        var pins = c['pinConfigs'];
        if (pins != null) {
          var pinConfigs = [];
          for (var p in pins) {
            var number = p['number'];
            var pinName = p['name'];
            pinConfigs.add(PinConfig(number: number, name: pinName));
          }
        }
        butlerConfigs.add(ButlerConfig(id: id, name: name));
      }
      this._butlerConfigs = butlerConfigs;
    }
    return this._butlerConfigs;
  }

  Future<File> get _localButlerFile async {
    final path = await _localPath;
    return File('$path/butler_configs.json');
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> writeButlerConfig(List<ButlerConfig> butlerConfigs) async {
    final file = await _localButlerFile;

    // Write the file.
    return file.writeAsString('$butlerConfigs');
  }

  bool _isEmpty(String string) {
    return string == null || string.isEmpty;
  }

  Future<SettingsState> reload() async {
    try {
      await _readMqttSettings();

      this._mqttClient = _getMqttClient(_mqttConfig);
      await this
          ._mqttClient
          .connect(_mqttConfig.username, _mqttConfig.password);
    } catch (e) {
      log("Cloud not reload settings", error: e);
      return SettingsError(
          "Could not establish connection to the mqtt server.");
    }
    try {
      await _readButlerConfigs();
    } catch (error, s) {
      log("Cloud not reload settings", error: error, stackTrace: s);
      return SettingsError("Could not read butler configs file..");
    }
    return SettingsLoaded(
        mqttClient: this._mqttClient,
        mqttConfig: this._mqttConfig,
        butlerConfigs: this._butlerConfigs);
  }

  SettingsState settingsState() {
    return SettingsLoaded(
        mqttConfig: _mqttConfig,
        mqttClient: _mqttClient,
        butlerConfigs: _butlerConfigs);
  }

  MqttClient _getMqttClient(MqttConfig mqttConfig) {
    var mqttClient = MqttServerClient.withPort(
        mqttConfig.hostname, mqttConfig.client_id, mqttConfig.port);
    mqttClient.secure = true;
    mqttClient.autoReconnect = true;
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

    var mqttHost = prefs.getString("mqttHost");
    var mqttPort = prefs.getInt("mqttPort");
    var mqttUsername = prefs.getString("mqttUsername");
    var mqttPassword = prefs.getString("mqttPassword");

    this._mqttConfig = MqttConfig(_uuid.v1(),
        hostname: mqttHost != null ? mqttHost.trim() : null,
        port: mqttPort,
        username: mqttUsername != null ? mqttUsername.trim() : null,
        password: mqttPassword != null ? mqttPassword.trim() : null);

    return this._mqttConfig;
  }

  Future<void> saveMqttSettings(String hostname, int port, String username,
      String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        "mqttHost", hostname != null ? hostname.trim() : null);
    await prefs.setInt("mqttPort", port);
    await prefs.setString(
        "mqttUsername", username != null ? username.trim() : null);
    await prefs.setString(
        "mqttPassword", password != null ? password.trim() : null);
  }

  ButlerConfig findButler(String id) {
    try {
      return this._butlerConfigs.firstWhere((element) => element.id == id);
    } catch (e) {
      // no element found
    }
    return null;
  }

  saveButler(ButlerConfig butler) async {
    if (findButler(butler.id) != null) {
      throw "A butler with this id already exists";
    }
    var configs = List<ButlerConfig>.from(this._butlerConfigs);
    configs.add(butler);
    await writeButlerConfig(configs);
    this._butlerConfigs.add(butler);
  }

  Future<SettingsLoaded> deleteButler(String id) async {
    var configs = List<ButlerConfig>.from(this._butlerConfigs);
    configs.removeWhere((element) => element.id == id);
    await writeButlerConfig(configs);
    this._butlerConfigs = configs;
    return SettingsLoaded(
        mqttConfig: _mqttConfig,
        mqttClient: _mqttClient,
        butlerConfigs: configs);
  }
}
