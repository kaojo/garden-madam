import 'dart:collection';

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
  final String cron_expression;
  final int duration_seconds;

  MqttSchedule(this.cron_expression, this.duration_seconds);
}
