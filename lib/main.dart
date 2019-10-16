import 'package:dependencies_flutter/dependencies_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garden_madam/datahandlers/health_status_mqtt_client.dart';
import 'package:garden_madam/datahandlers/layout_status_handler.dart';
import 'package:garden_madam/datahandlers/schedule_status_handler.dart';
import 'package:garden_madam/repositories/butler-repository.dart';
import 'package:garden_madam/mqtt.dart';
import 'package:garden_madam/ui/butler-page.dart';
import 'package:mqtt_client/mqtt_client.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Garden Madam',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MqttModule(
        child: RepositoryProvider(
          builder: (context) => _buildButlerRepository("local", "Virtueller Dev Buttler", context),
          child: ButlerPage(),
        ),
      ),
    );
  }

}

ButlerRepository _buildButlerRepository(String deviceId, String butlerName, BuildContext context) {
  //final injector = InjectorWidget.of(context);
//  final mqttClient = injector.get<MqttClient>();
//  final mqttConfig = injector.get<MqttConfig>();
  final mqttConfig = MqttConfig(
      "mqtt.flespi.io",
      8883,
      "FlespiToken 2PytGtM3gJZWa4JmJy1cDYuTkeZAmubd7xwCP8vVFiFEcdQKBFM2r4JB8wZjOZmM",
      "",
      "garden_madam_dev");
  var mqttClient = MqttClient.withPort(
      mqttConfig.hostname, mqttConfig.client_id, mqttConfig.port);

  return ButlerRepository(
    id: deviceId,
    name: butlerName,
    mqttClient: mqttClient,
    mqttConfig: mqttConfig,
    butlerHealthStatusMqttClient:
    ButlerHealthStatusMqttClient(mqttClient: mqttClient),
    butlerLayoutStatusMqttClient:
    ButlerLayoutStatusMqttClient(mqttClient: mqttClient),
    butlerWateringScheduleStatusMqttClient:
    ButlerWateringScheduleStatusMqttClient(mqttClient: mqttClient),
  );
}
