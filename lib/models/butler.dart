import 'dart:collection';

import 'package:garden_madam/blocs/blocs.dart';
import 'package:garden_madam/models/pin.dart';

class Butler {
  final String name;
  final String id;
  final ButlerConfig butlerConfig;
  List<Pin> _pins;
  bool online = false;

  UnmodifiableListView<Pin> get pins =>
      _pins != null ? UnmodifiableListView(_pins) : UnmodifiableListView([]);

  Butler({this.id, this.name, this.butlerConfig});

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

  @override
  String toString() {
    return 'Butler{name: $name, id: $id, _pins: $_pins, online: $online}';
  }
}
