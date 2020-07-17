import 'package:flutter/material.dart';

class NavigationDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(
              "Mqtt Settings",
              textScaleFactor: 1.5,
            ),
          )
        ],
      ),
    );
  }
}
