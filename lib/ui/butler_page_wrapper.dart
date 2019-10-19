import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garden_madam/blocs/blocs.dart';
import 'package:garden_madam/models/models.dart';
import 'package:garden_madam/mqtt.dart';
import 'package:garden_madam/repositories/butler_repository.dart';
import 'package:garden_madam/ui/butler_page.dart';
import 'package:mqtt_client/mqtt_client.dart';

class ButlerPageWrapper extends StatelessWidget {
  const ButlerPageWrapper({
    Key key,
    @required this.butlerId,
    @required this.butlerName,
    @required this.mqttConfig,
    @required this.mqttClient,
  }) : super(key: key);

  final MqttConfig mqttConfig;
  final MqttClient mqttClient;
  final String butlerId;
  final String butlerName;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      builder: (context) {
        ButlerRepository butlerRepository = _buildButlerRepository(context);
        butlerRepository.connect(Butler(butlerId, butlerName));
        return butlerRepository;
      },
      child: BlocProvider(
        builder: (context) {
          var bloc = ButlerBloc(
            butlerRepository: RepositoryProvider.of<ButlerRepository>(context),
          );
          bloc.init();
          return bloc;
        },
        child: ButlerPage(butlerName),
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
