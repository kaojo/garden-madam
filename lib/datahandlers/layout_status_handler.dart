import 'dart:collection';

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
