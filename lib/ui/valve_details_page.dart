import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:garden_madam/models/models.dart';

import 'detail_image_composition.dart';

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
  final Pin _pin;

  ValvePage(this._pin);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pin.name()),
      ),
      body: ListView(
        children: <Widget>[
          DetailImageComposition(
            status: _pin.status == Status.ON,
            onColor: Colors.blue,
            offColor: Colors.grey,
            child: Hero(
              tag: _pin.valvePinNumber,
              child: SvgPicture.asset(
                'images/' +
                    (_pin.imageName != null ? _pin.imageName : 'valve_1.svg'),
                semanticsLabel: 'Valve default image',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
