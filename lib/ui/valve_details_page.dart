import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:garden_madam/models/models.dart';
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
            title: Text("On/Off", style: TextStyle(fontWeight: FontWeight.bold),),
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
          ListTile(
            leading: Switch(
              value: false,
              onChanged: (bool newValue) {
                // Add your onChanged code here!
              },
            ),
            title: Text("17:00 - 18:00"),
            trailing: IconButton(icon: Icon(Icons.delete, color: Colors.grey)),
          ),
          ListTile(
            leading: Switch(
              value: true,
              onChanged: (bool newValue) {
                // Add your onChanged code here!
              },
            ),
            title: Text("09:00 - 09:30"),
            trailing: IconButton(icon: Icon(Icons.delete, color: Colors.grey)),
          ),
          ListTile(
            title: RaisedButton(
              onPressed: () {
                // Do stuff
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
}
