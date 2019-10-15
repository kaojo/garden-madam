import 'package:flutter/material.dart';
import 'package:garden_madam/datahandlers/health_status_mqtt_client.dart';
import 'package:garden_madam/datahandlers/layout_status_handler.dart';
import 'package:garden_madam/datahandlers/schedule_status_handler.dart';
import 'package:garden_madam/repositories/butler-repository.dart';
import 'package:garden_madam/datahandlers/mqtt.dart';
import 'package:mqtt_client/mqtt_client.dart';

import 'models/butler.dart';
import 'ui/butler_details_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var mqttConfig = MqttConfig(
        "mqtt.flespi.io",
        8883,
        "FlespiToken 2PytGtM3gJZWa4JmJy1cDYuTkeZAmubd7xwCP8vVFiFEcdQKBFM2r4JB8wZjOZmM",
        "",
        "garden_madam_dev");
    var mqttClient = MqttClient.withPort(
        mqttConfig.hostname, mqttConfig.client_id, mqttConfig.port);

    var butlerController = ButlerRepository(
      id: "local",
      name: "local development",
      mqttClient: mqttClient,
      mqttConfig: mqttConfig,
      butlerHealthStatusMqttClient:
          ButlerHealthStatusMqttClient(mqttClient: mqttClient),
      butlerLayoutStatusMqttClient:
          ButlerLayoutStatusMqttClient(mqttClient: mqttClient),
      butlerWateringScheduleStatusMqttClient:
          ButlerWateringScheduleStatusMqttClient(mqttClient: mqttClient),
    );

    return MaterialApp(
      title: 'Garden Madam',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: StreamBuilder<Butler>(
        stream: butlerController.stream, // a Stream<int> or null
        builder: (BuildContext context, AsyncSnapshot<Butler> snapshot) {
          Widget body;
          Butler butler;
          if (snapshot.hasError) {
            body = ListView(children: <Widget>[
              Text('Error: ${snapshot.error}'),
            ]);
          } else {
            switch (snapshot.connectionState) {
              case ConnectionState.active:
                butler = snapshot.data;
                body = butler != null
                    ? ButlerDetailsPage(butler, butlerController)
                    : _getLoadingPage();
                break;
              case ConnectionState.done:
                body = ListView(
                  children: <Widget>[
                    Text('No connection to butler.'),
                  ],
                );
                break;
              default:
                body = _getLoadingPage();
                break;
            }
          }
          return Scaffold(
            appBar: AppBar(
              title: butler != null && butler.name != null
                  ? Text(butler.name)
                  : Text('Loading'),
            ),
            body: RefreshIndicator(
              child: body,
              onRefresh: () => butlerController.refresh(),
            ),
          );
        },
      ),
    );
  }

  Center _getLoadingPage() {
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }
}
