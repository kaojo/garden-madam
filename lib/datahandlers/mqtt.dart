import 'dart:core';

class MqttConfig {
  final String hostname;
  final int port;
  final String username;
  final String password;
  final String client_id;

  MqttConfig(
      this.hostname, this.port, this.username, this.password, this.client_id);
}
