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
      onTap: () {print("tap");},
      leading: new GestureDetector(
        onTap: () => _pin.toggle(_butlerController),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
                width: 5,
                color:
                    _pin.status == Status.ON ? Colors.blue : Colors.grey),
            borderRadius: BorderRadius.circular(50),
          ),
          margin: const EdgeInsets.fromLTRB(4, 4, 50, 4),
          padding: EdgeInsets.all(5),
          width: 50,
          height: 50,
          alignment: Alignment.center,
          child: SvgPicture.asset(
              'images/' +
                  (_pin.imageName != null
                      ? _pin.imageName
                      : 'valve_1.svg'),
              semanticsLabel: 'Butler default image'),
        ),
      ),
      title: Text(
        _pin.name != null
            ? _pin.name
            : _pin.valvePinNumber.toString(),
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      trailing: _getScheduleIcon(_pin),

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
