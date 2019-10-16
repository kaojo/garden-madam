import 'dart:core';

import 'package:dependencies/dependencies.dart';
import 'package:dependencies_flutter/dependencies_flutter.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';

class MqttConfig {
  final String hostname;
  final int port;
  final String username;
  final String password;
  // ignore: non_constant_identifier_names
  final String client_id;

  MqttConfig(
      this.hostname, this.port, this.username, this.password, this.client_id);
}

class MqttModule extends ModuleWidget {

  const MqttModule({Key key, @required child}) : super(key: key, child: child);

  @override
  void configure(Binder binder) {
    print("Configuring MqttModule.");
    var mqttConfig = _getMqttConfig();
    var mqttClient = MqttClient.withPort(
        mqttConfig.hostname, mqttConfig.client_id, mqttConfig.port);

    binder
      ..bindSingleton(mqttConfig, name: "mqtt.config")
      ..bindSingleton(mqttClient, name: "mqtt.client");
  }
}

MqttConfig _getMqttConfig() {
  return MqttConfig(
      "mqtt.flespi.io",
      8883,
      "FlespiToken 2PytGtM3gJZWa4JmJy1cDYuTkeZAmubd7xwCP8vVFiFEcdQKBFM2r4JB8wZjOZmM",
      "",
      "garden_madam_dev");
}
