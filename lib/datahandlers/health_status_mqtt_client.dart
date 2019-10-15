import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';

class ButlerHealthStatusMqttClient {
  final MqttClient mqttClient;

  ButlerHealthStatusMqttClient({@required this.mqttClient});

  String _getHealthStatusTopic(String deviceId) {
    return '$deviceId/garden-butler/status/health';
  }

  Stream<MqttHealthStatus> getHealthStatus(String deviceId) {
    if (mqttClient.getSubscriptionsStatus(_getHealthStatusTopic(deviceId)) ==
        MqttSubscriptionStatus.doesNotExist) {
      _subscribe(deviceId);
    }
    return mqttClient.updates
        .where((event) => _isHealthStatusMessage(event, deviceId))
        .map((event) => _mapToHealthStatus(event, deviceId));
  }

  void _subscribe(String deviceId) {
    mqttClient.subscribe(_getHealthStatusTopic(deviceId), MqttQos.exactlyOnce);
  }

  bool _isHealthStatusMessage(
      List<MqttReceivedMessage<MqttMessage>> event, String deviceId) {
    return event != null &&
        event.isNotEmpty &&
        event
            .where((m) => m.topic == _getHealthStatusTopic(deviceId))
            .isNotEmpty;
  }

  MqttHealthStatus _mapToHealthStatus(
      List<MqttReceivedMessage<MqttMessage>> event, String deviceId) {
    var messageWrapper =
        event.firstWhere((m) => m.topic == _getHealthStatusTopic(deviceId));

    MqttPublishMessage publishMessage = messageWrapper.payload;
    var payload = MqttPublishPayload.bytesToStringAsString(
        publishMessage.payload.message);
    print(payload);

    var healthStatus;
    if (payload == "ONLINE") {
      healthStatus = MqttHealthStatus.online;
    } else if (payload == "OFFLINE") {
      healthStatus = MqttHealthStatus.offline;
    } else {
      throw Exception(
          ["Invalid payload for healt status message received: $payload"]);
    }
    return healthStatus;
  }
}

enum MqttHealthStatus {
  online,
  offline,
}
