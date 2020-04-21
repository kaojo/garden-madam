import 'package:flutter/material.dart';

abstract class ScheduleEvent {
  const ScheduleEvent();
}

class ScheduleStartDateSetEvent extends ScheduleEvent {
  final TimeOfDay time;

  ScheduleStartDateSetEvent(this.time);

  @override
  String toString() {
    return 'ScheduleStartDateSetEvent{time: $time}';
  }
}

class ScheduleEndDateSetEvent extends ScheduleEvent {
  final TimeOfDay time;

  ScheduleEndDateSetEvent(this.time);

  @override
  String toString() {
    return 'ScheduleEndDateSetEvent{time: $time}';
  }
}
