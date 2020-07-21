import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garden_madam/blocs/blocs.dart';
import 'package:garden_madam/models/models.dart';

import 'theme.dart';

class ValveSwitch extends StatelessWidget {
  final Pin _pin;

  const ValveSwitch(this._pin);

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _pin.status == Status.ON,
      onChanged: (newValue) => togglePin(context, _pin, newValue),
      activeColor: VALVE_ACTIVE_COLOR,
    );
  }

  togglePin(BuildContext context, Pin pin, bool newValue) {
      ToggleValveEvent toggleValveEvent = _createToggleEvent(pin);
      _dispatchEvent(context, toggleValveEvent);
  }

  void _dispatchEvent(BuildContext context, ButlerEvent event) {
    BlocProvider.of<ButlerBloc>(context).add(event);
  }

  ToggleValveEvent _createToggleEvent(Pin pin) {
    var direction = _determineToggleDirection();
    return ToggleValveEvent(pin: pin, toggleDirection: direction);
  }

  _determineToggleDirection() {
    var direction;
    if (_pin.isTurnedOn()) {
      direction = ToggleDirection.off;
    } else {
      direction = ToggleDirection.on;
    }
    return direction;
  }

}
