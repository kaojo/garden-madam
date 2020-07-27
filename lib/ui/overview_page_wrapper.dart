import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garden_madam/blocs/blocs.dart';
import 'package:garden_madam/blocs/butler_bloc.dart';
import 'package:garden_madam/models/butler.dart';
import 'package:garden_madam/models/mqtt.dart';
import 'package:garden_madam/repositories/butler_repository.dart';
import 'package:garden_madam/repositories/settings_repository.dart';
import 'package:garden_madam/ui/butler_card.dart';
import 'package:garden_madam/ui/scaffold.dart';
import 'package:garden_madam/ui/theme.dart';
import 'package:mqtt_client/mqtt_client.dart';

import 'add_buttler_page.dart';

class OverviewPageWrapper extends StatelessWidget {
  final MqttConfig mqttConfig;
  final MqttClient mqttClient;
  final List<ButlerConfig> butlerConfigs;

  const OverviewPageWrapper(
      {Key key, this.mqttConfig, this.mqttClient, this.butlerConfigs})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToAddButlerPage(context);
        },
        child: Icon(Icons.add),
        backgroundColor: APPBAR_COLOR,
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            BlocProvider.of<SettingsBloc>(context).add(SettingsReloadEvent()),
        child: this.butlerConfigs != null && this.butlerConfigs.isNotEmpty
            ? ListView(
                children: this
                    .butlerConfigs
                    .map((butlerConfig) => _butlerCard(context, butlerConfig))
                    .toList(),
              )
            : ListView(
                children: <Widget>[Text("Welcome. Please add a butler.")]),
      ),
    );
  }

  _navigateToAddButlerPage(BuildContext context) async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext newContext) {
      return AddButlerPage(
        settingsRepository: RepositoryProvider.of<SettingsRepository>(context),
      );
    }));
    BlocProvider.of<SettingsBloc>(context).add(SettingsReloadEvent());
  }

  Widget _butlerCard(BuildContext context, ButlerConfig butlerConfig) {
    return RepositoryProvider(
      create: (context) {
        ButlerRepository butlerRepository = _buildButlerRepository(context);
        butlerRepository.connect(Butler(
            id: butlerConfig.id,
            name: butlerConfig.name,
            butlerConfig: butlerConfig));
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
