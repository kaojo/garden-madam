import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garden_madam/blocs/blocs.dart';
import 'package:garden_madam/datahandlers/health_status_mqtt_client.dart';
import 'package:garden_madam/datahandlers/layout_status_handler.dart';
import 'package:garden_madam/datahandlers/schedule_status_handler.dart';
import 'package:garden_madam/repositories/butler_repository.dart';
import 'package:garden_madam/mqtt.dart';
import 'package:garden_madam/ui/butler_page.dart';
import 'package:mqtt_client/mqtt_client.dart';

import 'package:bloc/bloc.dart';

import 'models/models.dart';

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
    var butlerName = "Virtueller Dev Buttler";
    return MaterialApp(
      title: 'Garden Madam',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: RepositoryProvider(
        builder: (context) {
          ButlerRepository butlerRepository = _buildButlerRepository(context);
          butlerRepository.connect(Butler("local", butlerName));
          return butlerRepository;
        },
        child: BlocProvider(
          builder: (context) {
            var bloc = ButlerBloc(
                butlerRepository:
                    RepositoryProvider.of<ButlerRepository>(context));
            bloc.dispatch(FetchButler());
            return bloc;
          },
          child: ButlerPage(butlerName),
        ),
      ),
    );
  }
}

ButlerRepository _buildButlerRepository(BuildContext context) {
  // TODO load mqtt config from local storage or something
  final mqttConfig = MqttConfig(
      "mqtt.flespi.io",
      8883,
      "FlespiToken 2PytGtM3gJZWa4JmJy1cDYuTkeZAmubd7xwCP8vVFiFEcdQKBFM2r4JB8wZjOZmM",
      "",
      "garden_madam_dev");
  var mqttClient = MqttClient.withPort(
      mqttConfig.hostname, mqttConfig.client_id, mqttConfig.port);

  return ButlerRepository(
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
