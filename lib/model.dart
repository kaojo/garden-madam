import 'dart:collection';

import 'dart:math';

class Butler {
  final String name;
  final String id;
  List<Pin> _pins;
  bool online = false;

  UnmodifiableListView<Pin> get pins => _pins != null ? UnmodifiableListView(_pins) : UnmodifiableListView([]);

  Butler(this.id, this.name);
  Pin findPin(int pinNumber) {
    for (var pin in this.pins) {
      if (pin.valvePinNumber == pinNumber) {
        return pin;
      }
    }
    return null;
  }

  void addPin(Pin pin) {
    if (this.findPin(pin.valvePinNumber) == null) {
      if (this._pins == null) {
        this._pins = List();
      }
      this._pins.add(pin);
    }
  }
}

class Pin {
  String name;
  final int valvePinNumber;
  int buttonPinNumber;
  int statusPinNumber;
  Status status = Status.OFF;
  Schedule schedule;
  String imageName;

  Pin(this.valvePinNumber);

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
