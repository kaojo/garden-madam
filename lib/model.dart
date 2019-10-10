import 'dart:collection';

import 'package:garden_madam/butler-feed.dart';


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
  String _name;
  final int valvePinNumber;
  int buttonPinNumber;
  int statusPinNumber;
  Status status = Status.OFF;
  Schedule schedule;
  String imageName;

  Pin(this.valvePinNumber);

  String name() {
    if (_name != null && _name != "") {
      return _name;
    } else {
      return "Pin " + valvePinNumber.toString();
    }
  }
}
class Schedule {
  bool enabled = true;
  String cronExpression;
  int durationSeconds;

  Schedule(this.cronExpression, this.durationSeconds, {this.enabled = true});

}

enum RepeatRate { HOURLY, DAILY, WEEKLY }

enum Status { ON, OFF }
