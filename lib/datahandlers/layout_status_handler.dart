import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';

class ButlerLayoutStatusMqttClient {
  final MqttClient mqttClient;

  ButlerLayoutStatusMqttClient({@required this.mqttClient});

  String _getLayoutStatusTopic(String deviceId) {
    return '$deviceId/garden-butler/status/layout';
  }

  Stream<MqttLayoutStatus> getLayoutStatus(String deviceId) {
    if (mqttClient.getSubscriptionsStatus(_getLayoutStatusTopic(deviceId)) ==
        MqttSubscriptionStatus.doesNotExist) {
      _subscribe(deviceId);
    }
    return mqttClient.updates
        .where((event) => _isLayoutStatusMessage(event, deviceId))
        .map((event) => _mapToHealthStatus(event, deviceId));
  }

  void _subscribe(String deviceId) {
    mqttClient.subscribe(_getLayoutStatusTopic(deviceId), MqttQos.exactlyOnce);
  }

  bool _isLayoutStatusMessage(
      List<MqttReceivedMessage<MqttMessage>> event, String deviceId) {
    return event != null &&
        event.isNotEmpty &&
        event
            .where((m) => m.topic == _getLayoutStatusTopic(deviceId))
            .isNotEmpty;
  }

  MqttLayoutStatus _mapToHealthStatus(
      List<MqttReceivedMessage<MqttMessage>> event, String deviceId) {
    var messageWrapper =
    event.firstWhere((m) => m.topic == _getLayoutStatusTopic(deviceId));

    MqttPublishMessage publishMessage = messageWrapper.payload;
    var payload = MqttPublishPayload.bytesToStringAsString(
        publishMessage.payload.message);
    print(payload);

    var status =
        MqttLayoutStatus.fromJson(json.decode(payload));
    return status;
  }
}

class MqttLayoutStatus {
  List<MqttValve> _valves;

  UnmodifiableListView<MqttValve> get valves => _valves != null
      ? UnmodifiableListView(_valves)
      : UnmodifiableListView([]);

  MqttLayoutStatus(this._valves);

  MqttLayoutStatus.fromJson(Map<String, dynamic> json) {
    var valves = json['valves'];

    this._valves = List();
    if (valves != null) {
      for (var v in valves) {
        var valve_pin_number = v['valve_pin_number'];
        var status = v['status'];
        if (status != null && valve_pin_number != null) {
          this
              ._valves
              .add(MqttValve(valve_pin_number, _valveStatusfromString(status)));
        }
      }
    }
  }
}

class MqttValve {
  final int valve_pin_number;
  final MqttValveStatus status;

  MqttValve(this.valve_pin_number, this.status);
}

enum MqttValveStatus {
  OPEN,
  CLOSED,
  UNKNOWN,
}

MqttValveStatus _valveStatusfromString(String s) {
  if (s == 'OPEN') {
    return MqttValveStatus.OPEN;
  }
  if (s == 'CLOSED') {
    return MqttValveStatus.CLOSED;
  }
  print('could not find MqttValveStatus for string $s');
  return MqttValveStatus.UNKNOWN;
}
