import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:garden_madam/models/schedule.dart';

class Pin {
  String name;
  final int valvePinNumber;
  Status status = Status.OFF;
  List<Schedule> _schedules = [];

  UnmodifiableListView<Schedule> get schedules => _schedules != null
      ? UnmodifiableListView(_schedules)
      : UnmodifiableListView([]);

  String imageName;

  Pin(this.valvePinNumber);

  void addSchedule(Schedule schedule) {
    if (findSchedule(schedule.startTime, schedule.endTime) == null) {
      _schedules.add(schedule);
    }
  }

  Schedule findSchedule(TimeOfDay startTime, TimeOfDay endTime) {
    for (var schedule in this.schedules) {
      if (schedule.startTime == startTime && schedule.endTime == endTime) {
        return schedule;
      }
    }
    return null;
  }

  removeSchedule(Schedule schedule) {
    for (var i = 0; i < _schedules.length; ++i) {
      var tempSchedule = _schedules[i];
      if (schedule.startTime == tempSchedule.startTime &&
          schedule.endTime == tempSchedule.endTime) {
        _schedules.removeAt(i);
        return;
      }
    }
  }

  String displayName() {
    if (name != null && name != "") {
      return name;
    } else {
      return "Pin " + valvePinNumber.toString();
    }
  }

  void turnOff() {
    status = Status.OFF;
  }

  void turnOn() {
    status = Status.ON;
  }

  bool isTurnedOn() {
    return status == Status.ON;
  }

  @override
  String toString() {
    return 'Pin{name: $name, valvePinNumber: $valvePinNumber, status: $status, _schedules: $_schedules, imageName: $imageName}';
  }
}

enum Status { ON, OFF }
