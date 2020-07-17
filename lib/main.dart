import 'dart:developer';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:garden_madam/blocs/blocs.dart';
import 'package:garden_madam/repositories/settings_repository.dart';
import 'package:garden_madam/ui/mqtt_settings_form.dart';
import 'package:garden_madam/ui/overview_page_wrapper.dart';

import 'ui/scaffold.dart';
import 'ui/theme.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    log(transition.toString());
  }
}

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garden Madam',
      theme: ThemeData(
        primarySwatch: APPBAR_COLOR,
      ),
      home: RepositoryProvider(
        create: (context) {
          SettingsRepository repository = new SettingsRepository();
          return repository;
        },
        child: BlocProvider(
          create: (context) {
            var bloc = SettingsBloc(
              RepositoryProvider.of<SettingsRepository>(context),
            );
            return bloc;
          },
          child: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, SettingsState state) {
              if (state is SettingsLoading) {
                return MyScaffold(body: loadingAnimation());
              } else if (state is SettingsError) {
                return MyScaffold(body: Text("error"));
              } else if (state is InvalidMqttSettings) {
                return MyScaffold(body: invalidMqttSettings(context));
              } else if (state is SettingsLoaded) {
                return OverviewPageWrapper(
                  mqttConfig: state.mqttConfig,
                  mqttClient: state.mqttClient,
                );
              }
              return Text("error");
            },
          ),
        ),
      ),
    );
  }

  Widget invalidMqttSettings(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(10),
          child: Center(
            child: Text(
              "Invalid MQTT settings",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 28),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(10),
          child: Center(
            child: RichText(
              text: TextSpan(
                  text:
                  "In order to connect to your garden buttler, the garden madam need to connect to the same MQTT message broker. Please provide valid credentials.",
                  style: TextStyle(fontSize: 20, color: Colors.blueGrey),
                  children: []),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(10),
          child: Center(
            child: RaisedButton(
              onPressed: () => _navigateToMqttSettingsForm(context),
              child: Text('Edit mqtt settings'),
            ),
          ),
        )
      ],
    );
  }
}

_navigateToMqttSettingsForm(BuildContext context) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (BuildContext newContext) {
        return MqttSettingsForm(
            RepositoryProvider.of<SettingsRepository>(context));
      },
    ),
  );
  BlocProvider.of<SettingsBloc>(context).add(SettingsReloadEvent());
}

Widget loadingAnimation() {
  return new Center(
    child: new CircularProgressIndicator(),
  );
}
