import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:garden_madam/blocs/blocs.dart';
import 'package:garden_madam/models/models.dart';

import 'valve_details_page.dart';

class ValvesListItem extends StatelessWidget {
  final Pin _pin;

  ValvesListItem(this._pin);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return ValvePage(_pin);
        }));
      },
      contentPadding: EdgeInsets.only(left: 10, bottom: 20.0),
      leading: Container(
        decoration: BoxDecoration(
          border: Border.all(
              width: 4,
              color: _pin.status == Status.ON ? Colors.blue : Colors.grey),
          borderRadius: BorderRadius.circular(45),
        ),
        padding: EdgeInsets.all(5),
        width: 45,
        height: 45,
        alignment: Alignment.center,
        child: Hero(
          tag: _pin.valvePinNumber,
          child: SvgPicture.asset(
              'images/' +
                  (_pin.imageName != null ? _pin.imageName : 'valve_1.svg'),
              semanticsLabel: 'Valve default image'),
        ),
      ),
      title: Text(
        _pin.name(),
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      trailing: Switch(
        value: _pin.status == Status.ON,
        onChanged: (newValue) => togglePin(context, _pin, newValue),
      ),
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
    var butlerBloc = BlocProvider.of<ButlerBloc>(context);
    butlerBloc.dispatch(event);
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
    print(e);
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