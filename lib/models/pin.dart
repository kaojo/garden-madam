
import 'package:garden_madam/models/schedule.dart';

class Pin {
  String _name;
  final int valvePinNumber;
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
