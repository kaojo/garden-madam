
import 'package:garden_madam/models/schedule.dart';

class Pin {
  String name;
  final int valvePinNumber;
  Status status = Status.OFF;
  Schedule schedule;
  String imageName;

  Pin(this.valvePinNumber);

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
}

enum Status { ON, OFF }
