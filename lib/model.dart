import 'dart:collection';

import 'package:flutter/widgets.dart';

class Butler extends ChangeNotifier {
  String name;
  String id;
  List<Pin> _pins;
  bool online;

  UnmodifiableListView<Pin> get pins => UnmodifiableListView(_pins);

  Butler(this.name, this.id, this._pins, this.online);
}

class Pin {
  String name;
  int valvePinNumber;
  int buttonPinNumber;
  int statusPinNumber;
  Status status;
  Schedule schedule;

  Pin(this.name, this.valvePinNumber, this.buttonPinNumber,
      this.statusPinNumber, this.status, this.schedule);
}

class Schedule {
  bool enabled;
  int startHour;
  int startMinute;
  int endHour;
  int endMinute;
  RepeatRate repeatRate;

  Schedule(this.enabled, this.startHour, this.startMinute, this.endHour,
      this.endMinute, this.repeatRate);
}

enum RepeatRate { HOURLY, DAILY, WEEKLY }

enum Status { ON, OFF }
