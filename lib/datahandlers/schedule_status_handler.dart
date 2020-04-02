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
    if (mqttClient.getSubscriptionsStatus(
            _getWateringScheduleStatusTopic(deviceId)) ==
        MqttSubscriptionStatus.doesNotExist) {
      _subscribe(deviceId);
    }
    return mqttClient.updates
        .where((event) => _isWateringScheduleStatusMessage(event, deviceId))
        .map((event) => _mapToHealthStatus(event, deviceId));
  }

  void _subscribe(String deviceId) {
    mqttClient.subscribe(
        _getWateringScheduleStatusTopic(deviceId), MqttQos.exactlyOnce);
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
    var messageWrapper = event.firstWhere(
        (m) => m.topic == _getWateringScheduleStatusTopic(deviceId));

    MqttPublishMessage publishMessage = messageWrapper.payload;
    var payload = MqttPublishPayload.bytesToStringAsString(
        publishMessage.payload.message);
    print(payload);

    var status = MqttWateringSchedule.fromJson(json.decode(payload));
    return status;
  }
}

class MqttWateringSchedule {
  List<MqttValveSchedule> _schedules;

  UnmodifiableListView<MqttValveSchedule> get schedules => _schedules != null
      ? UnmodifiableListView(_schedules)
      : UnmodifiableListView([]);

  MqttWateringSchedule.fromJson(Map<String, dynamic> json) {
    var schedules = json['schedules'];
    if (schedules != null) {
      this._schedules = List();
      for (var valveSchedule in schedules) {
        var valve = valveSchedule['valve'];
        var enabled = valveSchedule['enabled'];
        var schedule = valveSchedule['schedule'];
        if (schedule != null) {
          this._schedules.add(
                MqttValveSchedule(
                    valve,
                    MqttSchedule(
                      schedule['start_hour'],
                      schedule['start_minute'],
                      schedule['end_hour'],
                      schedule['end_minute'],
                    ),
                    enabled),
              );
        } else {
          print("Could not parse schedule: $schedule");
        }
      }
    }
  }
}

class MqttValveSchedule {
  final int valve;
  final MqttSchedule schedule;
  final bool enabled;

  MqttValveSchedule(this.valve, this.schedule, this.enabled);
}

class MqttSchedule {
  // ignore: non_constant_identifier_names
  final int start_hour;

  // ignore: non_constant_identifier_names
  final int start_minute;

  // ignore: non_constant_identifier_names
  final int end_hour;

  // ignore: non_constant_identifier_names
  final int end_minute;

  MqttSchedule(
    this.start_hour,
    this.start_minute,
    this.end_hour,
    this.end_minute,
  );
}
