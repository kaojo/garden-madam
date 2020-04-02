import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:garden_madam/models/models.dart';
import 'package:garden_madam/ui/schedule_list_tile.dart';
import 'package:garden_madam/ui/valve_detail_image_composition.dart';
import 'package:garden_madam/ui/valve_switch.dart';

import 'theme.dart';

class ValvePage extends StatelessWidget {
  final Pin pin;

  const ValvePage({Key key, this.pin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pin.displayName()),
      ),
      body: ListView(
        children: <Widget>[
          ValveDetailImageComposition(pin: pin),
          ListTile(
            leading: ValveSwitch(pin),
            title: Text(
              "On/Off",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Text("00:00:00"),
          ),
          Divider(
            thickness: 2.0,
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              "Schedules",
              textScaleFactor: 1.5,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ...getScheduleListTiles(),
          ListTile(
            title: RaisedButton(
              onPressed: () {
                // Open "add schedule dialog"
              },
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.add_circle_outline,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 5.0),
                      child: Text("Add Schedule"),
                    ),
                  ],
                ),
              ),
              color: APPBAR_COLOR,
            ),
          ),
        ],
      ),
    );
  }

  List<ScheduleListTile> getScheduleListTiles() => pin.schedules
        .map((schedule) => ScheduleListTile(schedule: schedule))
        .toList();
}
