import 'dart:core';

class MqttConfig {
  final String hostname;
  final int port;
  final String username;
  final String password;

  // ignore: non_constant_identifier_names
  final String client_id;

  const MqttConfig(this.client_id,
      {this.hostname, this.port, this.username, this.password});
}
