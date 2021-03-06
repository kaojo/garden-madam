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
import 'package:garden_madam/ui/error_message.dart';
import 'package:garden_madam/ui/mqtt_settings_form.dart';
import 'package:garden_madam/ui/overview_page_wrapper.dart';

import 'ui/scaffold.dart';
import 'ui/theme.dart';

class SimpleBlocDelegate extends BlocObserver {
  @override
  onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    log(transition.toString());
  }
}

void main() {
  Bloc.observer = SimpleBlocDelegate();
  var settingsRepository = new SettingsRepository();
  runApp(MyApp(settingsRepository: settingsRepository));
}

class MyApp extends StatelessWidget {
  final SettingsRepository settingsRepository;

  const MyApp({Key key, this.settingsRepository}) : super(key: key);

// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) {
        return settingsRepository;
      },
      child: BlocProvider(
        create: (context) {
          var bloc = SettingsBloc(
            RepositoryProvider.of<SettingsRepository>(context),
          );
          bloc.init();
          return bloc;
        },
        child: MaterialApp(
          theme: ThemeData(
            primarySwatch: APPBAR_COLOR,
          ),
          home: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, SettingsState state) {
              if (state is SettingsLoading) {
                return MyScaffold(
                  body: loadingAnimation(),
                );
              } else if (state is SettingsError) {
                return _errorMessageWithReload(context, state.errorMessage);
              } else if (state is InvalidMqttSettings) {
                return invalidMqttSettings(context);
              } else if (state is SettingsLoaded) {
                return OverviewPageWrapper(
                  mqttConfig: state.mqttConfig,
                  mqttClient: state.mqttClient,
                  butlerConfigs: state.butlerConfigs,
                );
              }
              return _errorMessageWithReload(
                  context, "Unknown error detected.");
            },
          ),
        ),
      ),
    );
  }

  Widget _errorMessageWithReload(BuildContext context, String errorMessage) {
    return MyScaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          return await _reloadSettings(context);
        },
        child: ListView(
          children: <Widget>[
            ErrorMessage(errorMessage),
          ],
        ),
      ),
    );
  }

  Widget invalidMqttSettings(BuildContext context) {
    return MyScaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          return await _reloadSettings(context);
        },
        child: ListView(
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
        ),
      ),
    );
  }

  _reloadSettings(BuildContext context) async {
    log("reload settings on refresh.");
    BlocProvider.of<SettingsBloc>(context).add(SettingsReloadEvent());
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
