import 'package:flutter/material.dart';
import 'package:garden_madam/models/models.dart';
import 'package:garden_madam/ui/valve_detail_image_composition.dart';
import 'package:garden_madam/ui/valve_switch.dart';

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
  final Pin pin;

  const ValvePage({Key key, this.pin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pin.name()),
        actions: <Widget>[
          ValveSwitch(pin),
        ],
      ),
      body: ListView(
        children: <Widget>[
          ValveDetailImageComposition(pin: pin),
          ListTile(
            title: TextField(
              enabled: false,
              decoration: InputDecoration(labelText: "Name"),
              controller: TextEditingController(text: pin.name()),
            ),
          ),
          ListTile(
            title: TextField(
              enabled: false,
              decoration: InputDecoration(labelText: "Valve Pin"),
              controller:
                  TextEditingController(text: pin.valvePinNumber.toString()),
            ),
          ),
        ],
      ),
    );
  }
}
