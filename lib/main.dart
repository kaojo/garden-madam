import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:garden_madam/mqtt.dart';
import 'package:garden_madam/ui/butler_page_wrapper.dart';
import 'package:mqtt_client/mqtt_client.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
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
        "FlespiToken 2PytGtM3gJZWa4JmJy1cDYuTkeZAmubd7xwCP8vVFiFEcdQKBFM2r4JB8wZjOZmM",
        "",
        "garden_madam_dev");
    var mqttClient = MqttClient.withPort(
        mqttConfig.hostname, mqttConfig.client_id, mqttConfig.port);
    mqttClient.secure = true;
    mqttClient.onConnected = _onConnected;
    mqttClient.onSubscribed = _onSubscribed;

    return MaterialApp(
      title: 'Garden Madam',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: new ButlerPageWrapper(
        butlerId: "local",
        butlerName: "Virtueller Dev Buttler",
        mqttConfig: mqttConfig,
        mqttClient: mqttClient,
      ),
    );
  }

  void _onConnected() {
    print("connected successful");
  }

  void _onSubscribed(String topic) {
    print('Subscription confirmed for topic $topic');
  }
}
