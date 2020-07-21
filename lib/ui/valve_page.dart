import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:garden_madam/models/models.dart';
import 'package:garden_madam/ui/error_message.dart';
import 'package:garden_madam/ui/scaffold.dart';
import 'package:garden_madam/ui/schedule_list_tile.dart';
import 'package:garden_madam/ui/valve_detail_image_composition.dart';
import 'package:garden_madam/ui/valve_switch.dart';

import 'valve_schedule_add_button.dart';

class ValvePage extends StatelessWidget {
  final Pin pin;
  final String errorMessage;

  const ValvePage({Key key, this.pin, this.errorMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var list = List<Widget>();
    if (errorMessage != null) {
      list.add(ErrorMessage(errorMessage));
    }
    list.addAll(
      <Widget>[
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
        AddScheduleButton(
          pin: pin,
        ),
      ],
    );
    return MyScaffold(
      title: pin.displayName(),
      body: ListView(
        children: list,
      ),
    );
  }

  List<ScheduleListTile> getScheduleListTiles() => pin.schedules
      .map((schedule) => ScheduleListTile(schedule: schedule))
      .toList();
}
