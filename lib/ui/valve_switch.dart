import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garden_madam/blocs/blocs.dart';
import 'package:garden_madam/models/models.dart';

import 'theme.dart';

class ValveSwitch extends StatelessWidget {
  final Pin _pin;

  ValveSwitch(this._pin);

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _pin.status == Status.ON,
      onChanged: (newValue) => togglePin(context, _pin, newValue),
      activeColor: VALVE_ACTIVE_COLOR,
    );
  }

  togglePin(BuildContext context, Pin pin, bool newValue) {
    try {
      ToggleValveEvent toggleValveEvent = _createToggleEvent(pin);
      _dispatchEvent(context, toggleValveEvent);
    } on Exception catch (e) {
      _handleToggleError(context, _pin, newValue, e);
    }
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

  void _handleToggleError(
      BuildContext context, Pin pin, bool newValue, Exception e) {
    log(e.toString());
    _restoreOldPinStatus(pin, newValue);
    _displayErrorDialog(context);
  }

  void _displayErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Connection Error"),
          content: new Text("Could not reach your butler. Try again later."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _restoreOldPinStatus(Pin pin, bool newValue) {
    pin.status = newValue ? Status.OFF : Status.ON;
  }
}
