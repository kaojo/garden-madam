import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:garden_madam/mqtt.dart';
import 'package:garden_madam/ui/overview_page_wrapper.dart';
import 'package:mqtt_client/mqtt_client.dart';

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
    // TODO load mqtt config from local storage or something
    final mqttConfig = MqttConfig(
        "mqtt.flespi.io",
        8883,
        "FlespiToken 4ZbeXKnO1ZGNPdkwGyePJdzMsIOwCxAxmBz79MKYzgAejKyN6CtFFSfYpSiPfGcp",
        "",
        "garden_madam_dev");

    var mqttClient = MqttClient.withPort(
        mqttConfig.hostname, mqttConfig.client_id, mqttConfig.port);
    mqttClient.secure = true;
    mqttClient.onConnected = _onConnected;
    mqttClient.onSubscribed = _onSubscribed;
    //mqttClient.logging(on: true);

    return MaterialApp(
      title: 'Garden Madam',
      theme: ThemeData(
        primarySwatch: APPBAR_COLOR,
      ),
      home: OverviewPageWrapper(
        mqttClient: mqttClient,
        mqttConfig: mqttConfig,
      ),
    );
  }

  void _onConnected() {
    log("connected successful");
  }

  void _onSubscribed(String topic) {
    log('Subscription confirmed for topic $topic');
  }
}
