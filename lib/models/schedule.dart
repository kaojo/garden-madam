import 'package:flutter/material.dart';

class Schedule {
  int valvePin;
  bool enabled = true;
  TimeOfDay startTime;
  TimeOfDay endTime;

  Schedule(this.valvePin, this.startTime, this.endTime, {this.enabled = true});

  void disable() {
    enabled = false;
  }

  void enable() {
    enabled = true;
  }

  @override
  String toString() {
    return 'Schedule{valvePin: $valvePin, enabled: $enabled, startTime: $startTime, endTime: $endTime}';
  }
}
