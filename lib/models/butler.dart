import 'dart:collection';
import 'dart:developer';

import 'package:garden_madam/blocs/blocs.dart';
import 'package:garden_madam/models/pin.dart';

class Butler {
  final String name;
  final String id;
  ButlerConfig _butlerConfig;
  List<Pin> _pins;
  bool online = false;

  UnmodifiableListView<Pin> get pins =>
      _pins != null ? UnmodifiableListView(_pins) : UnmodifiableListView([]);

  ButlerConfig get butlerConfig => _butlerConfig;

  Butler({this.id, this.name, butlerConfig}) {
    this._butlerConfig = butlerConfig;
    log('$butlerConfig');
    _updatePins();
  }

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

  void updateButlerConfig(ButlerConfig butlerConfig) {
    this._butlerConfig = butlerConfig;
    _updatePins();
  }

  void _updatePins() {
    for (var pinConfig in this._butlerConfig.pinConfigs) {
      var pin = findPin(pinConfig.number);
      if (pin == null) {
        addPin(Pin(pinConfig.number, name: pinConfig.name));
      } else {
        pin.name = pinConfig.name;
      }
    }
  }

  @override
  String toString() {
    return 'Butler{name: $name, id: $id, _pins: $_pins, online: $online}';
  }
}
