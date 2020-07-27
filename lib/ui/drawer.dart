import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garden_madam/blocs/settings_bloc.dart';
import 'package:garden_madam/blocs/settings_event.dart';
import 'package:garden_madam/repositories/settings_repository.dart';

import 'mqtt_settings_form.dart';

class NavigationDrawer extends StatelessWidget {
  final List<Widget> pageDrawerItems;

  NavigationDrawer({List<Widget> pageDrawerItems})
      : this.pageDrawerItems = pageDrawerItems != null
            ? pageDrawerItems + <Widget>[Divider(thickness: 2.0)]
            : <Widget>[];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: pageDrawerItems +
            <Widget>[
              InkWell(
                onTap: () => _navigateToMqttSettingsPage(context),
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text(
                    "Mqtt Settings",
                    textScaleFactor: 1.5,
                  ),
                ),
              )
            ],
      ),
    );
  }
}

_navigateToMqttSettingsPage(BuildContext context) async {
  var result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (BuildContext newContext) {
        return MqttSettingsForm(
            RepositoryProvider.of<SettingsRepository>(context));
      },
    ),
  );
  if (result == "SUCCESS") {
    BlocProvider.of<SettingsBloc>(context).add(SettingsReloadEvent());
  }
  Navigator.pop(context);
}
