import 'dart:collection';

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
        if (schedule != null && schedule['cron_expression'] != null && schedule['duration_seconds'] != null) {
          this._schedules.add(MqttValveSchedule(valve, MqttSchedule(schedule['cron_expression'], schedule['duration_seconds'])));
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
  final String cron_expression;
  final int duration_seconds;

  MqttSchedule(this.cron_expression, this.duration_seconds);
}