import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garden_madam/blocs/butler_bloc.dart';
import 'package:garden_madam/models/butler.dart';
import 'package:garden_madam/mqtt.dart';
import 'package:garden_madam/repositories/butler_repository.dart';
import 'package:garden_madam/ui/butler_card.dart';
import 'package:mqtt_client/mqtt_client.dart';

import 'scaffold.dart';

class OverviewPageWrapper extends StatelessWidget {
  final MqttConfig mqttConfig;
  final MqttClient mqttClient;

  const OverviewPageWrapper({Key key, this.mqttConfig, this.mqttClient})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      title: "My Buttlers",
      body: _butlerCard(context),
    );
  }

  Widget _butlerCard(BuildContext context) {
    var butlerId = "raspi";
    var butlerName = "Balkon Butler";
    return RepositoryProvider(
      create: (context) {
        ButlerRepository butlerRepository = _buildButlerRepository(context);
        butlerRepository.connect(Butler(butlerId, butlerName));
        return butlerRepository;
      },
      child: BlocProvider(
        create: (context) {
          var bloc = ButlerBloc(
            butlerRepository: RepositoryProvider.of<ButlerRepository>(context),
          );
          bloc.init();
          return bloc;
        },
        child: ButlerCard(),
      ),
    );
  }

  ButlerRepository _buildButlerRepository(BuildContext context) {
    return ButlerRepository(
      mqttClient: mqttClient,
      mqttConfig: mqttConfig,
    );
  }
}
