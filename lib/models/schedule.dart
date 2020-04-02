
import 'package:flutter/material.dart';

class Schedule {
  bool enabled = true;
  TimeOfDay startTime;
  TimeOfDay endTime;

  Schedule(this.startTime, this.endTime, {this.enabled = true});

}
