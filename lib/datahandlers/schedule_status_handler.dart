import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';

class ButlerWateringScheduleStatusMqttClient {
  final MqttClient mqttClient;

  ButlerWateringScheduleStatusMqttClient({@required this.mqttClient});

  String _getWateringScheduleStatusTopic(String deviceId) {
    return '$deviceId/garden-butler/status/watering-schedule';
  }

  Stream<MqttWateringSchedule> getWateringScheduleStatus(String deviceId) {
    if (mqttClient.getSubscriptionsStatus(_getWateringScheduleStatusTopic(deviceId)) ==
        MqttSubscriptionStatus.doesNotExist) {
      _subscribe(deviceId);
    }
    return mqttClient.updates
        .where((event) => _isWateringScheduleStatusMessage(event, deviceId))
        .map((event) => _mapToHealthStatus(event, deviceId));
  }

  void _subscribe(String deviceId) {
    mqttClient.subscribe(_getWateringScheduleStatusTopic(deviceId), MqttQos.exactlyOnce);
  }

  bool _isWateringScheduleStatusMessage(
      List<MqttReceivedMessage<MqttMessage>> event, String deviceId) {
    return event != null &&
        event.isNotEmpty &&
        event
            .where((m) => m.topic == _getWateringScheduleStatusTopic(deviceId))
            .isNotEmpty;
  }

  MqttWateringSchedule _mapToHealthStatus(
      List<MqttReceivedMessage<MqttMessage>> event, String deviceId) {
    var messageWrapper =
    event.firstWhere((m) => m.topic == _getWateringScheduleStatusTopic(deviceId));

    MqttPublishMessage publishMessage = messageWrapper.payload;
    var payload = MqttPublishPayload.bytesToStringAsString(
        publishMessage.payload.message);
    print(payload);

    var status =
    MqttWateringSchedule.fromJson(json.decode(payload));
    return status;
  }
}

class MqttWateringSchedule {
  bool enabled;
  List<MqttValveSchedule> _schedules;

  UnmodifiableListView<MqttValveSchedule> get schedules => _schedules != null
      ? UnmodifiableListView(_schedules)
      : UnmodifiableListView([]);

  MqttWateringSchedule.fromJson(Map<String, dynamic> json) {
    this.enabled = json['enabled'];
    var schedules = json['schedules'];
    if (schedules != null) {
      this._schedules = List();
      for (var valveSchedule in schedules) {
        var valve = valveSchedule['valve'];
        var schedule = valveSchedule['schedule'];
        if (schedule != null &&
            schedule['cron_expression'] != null &&
            schedule['duration_seconds'] != null) {
          this._schedules.add(MqttValveSchedule(
              valve,
              MqttSchedule(
                  schedule['cron_expression'], schedule['duration_seconds'])));
        }
      }
    }
  }
}

class MqttValveSchedule {
  final int valve;
  final MqttSchedule schedule;

  MqttValveSchedule(this.valve, this.schedule);
}

class MqttSchedule {
  // ignore: non_constant_identifier_names
  final String cron_expression;
  // ignore: non_constant_identifier_names
  final int duration_seconds;

  MqttSchedule(this.cron_expression, this.duration_seconds);
}
