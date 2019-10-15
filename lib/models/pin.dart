
import 'package:garden_madam/models/schedule.dart';

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

enum Status { ON, OFF }