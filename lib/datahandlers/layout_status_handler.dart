import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:typed_data/typed_data.dart';

class ButlerLayoutStatusMqttClient {
  final MqttClient mqttClient;

  ButlerLayoutStatusMqttClient({@required this.mqttClient});

  String _getLayoutStatusTopic(String deviceId) {
    return '$deviceId/garden-butler/status/layout';
  }

  String _layoutOpenCommandTopic(String deviceId) {
    return '$deviceId/garden-butler/command/layout/open';
  }

  String _layoutCloseCommandTopic(String deviceId) {
    return '$deviceId/garden-butler/command/layout/close';
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
    log(payload);

    var status = MqttLayoutStatus.fromJson(json.decode(payload));
    return status;
  }

  Future<Void> turnOff(String deviceId, int valvePinNumber) async {
    Uint8Buffer buffer = _convertPinNumberToPayload(valvePinNumber);
    this.mqttClient.publishMessage(
        _layoutCloseCommandTopic(deviceId), MqttQos.exactlyOnce, buffer);
    return null;
  }

  Future<Void> turnOn(String deviceId, int valvePinNumber) async {
    Uint8Buffer buffer = _convertPinNumberToPayload(valvePinNumber);
    this.mqttClient.publishMessage(
        _layoutOpenCommandTopic(deviceId), MqttQos.exactlyOnce, buffer);

    return null;
  }

  Uint8Buffer _convertPinNumberToPayload(int valvePinNumber) {
    var data = utf8.encode(valvePinNumber.toString());
    var buffer = new Uint8Buffer();
    buffer.addAll(data);
    return buffer;
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
        var valvePinNumber = v['valve_pin_number'];
        var status = v['status'];
        if (status != null && valvePinNumber != null) {
          this
              ._valves
              .add(MqttValve(valvePinNumber, _valveStatusfromString(status)));
        }
      }
    }
  }

  @override
  String toString() {
    return 'MqttLayoutStatus{_valves: $_valves}';
  }
}

class MqttValve {
  // ignore: non_constant_identifier_names
  final int valve_pin_number;
  final MqttValveStatus status;

  MqttValve(this.valve_pin_number, this.status);

  @override
  String toString() {
    return 'MqttValve{valve_pin_number: $valve_pin_number, status: $status}';
  }
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
  log('could not find MqttValveStatus for string $s');
  return MqttValveStatus.UNKNOWN;
}
