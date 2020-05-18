import 'dart:core';

class MqttConfig {
  String hostname;
  int port;
  String username;
  String password;
  // ignore: non_constant_identifier_names
  final String client_id;

  MqttConfig(this.client_id,
      {this.hostname, this.port, this.username, this.password});

}

