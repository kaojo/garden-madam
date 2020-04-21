import 'package:flutter/material.dart';

class ScheduleState {
  TimeOfDay startTime;
  TimeOfDay endTime;

  ScheduleState({this.startTime, this.endTime});

  @override
  String toString() {
    return 'ScheduleState{startTime: $startTime, endTime: $endTime}';
  }
}
