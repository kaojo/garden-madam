import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:garden_madam/butler-feed.dart';

import '../model.dart';

class ValvesListItem extends StatelessWidget {
  ButlerController _butlerController;
  Pin _pin;

  ValvesListItem(this._butlerController, this._pin);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return ValvePage(_pin);
        }));
      },
      contentPadding: EdgeInsets.only(bottom: 20.0),
      leading: Container(
        decoration: BoxDecoration(
          border: Border.all(
              width: 5,
              color: _pin.status == Status.ON ? Colors.blue : Colors.grey),
          borderRadius: BorderRadius.circular(50),
        ),
        padding: EdgeInsets.all(5),
        width: 50,
        height: 50,
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
        onChanged: (bool newValue) {
          if (_pin.status == Status.ON) {
            _butlerController.turn_off(_pin);
          } else {
            _butlerController.turn_on(_pin);
          }
        },
      ),
    );
  }
}

Icon _getScheduleIcon(Pin pin) {
  if (pin.schedule == null) {
    return Icon(Icons.add_alarm, color: Colors.grey);
  }

  if (!pin.schedule.enabled) {
    return Icon(Icons.access_alarm, color: Colors.grey);
  }

  return Icon(Icons.access_alarm, color: Colors.lightBlueAccent);
}

class ValvePage extends StatelessWidget {
  Pin _pin;

  ValvePage(this._pin);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pin.name()),
      ),
      body: Hero(
        tag: _pin.valvePinNumber,
        child: SvgPicture.asset(
            'images/' +
                (_pin.imageName != null ? _pin.imageName : 'valve_1.svg'),
            semanticsLabel: 'Valve default image'),
      ),
    );
  }
}
