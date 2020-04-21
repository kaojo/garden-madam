import 'package:flutter/material.dart';
import 'package:garden_madam/models/butler.dart';
import 'package:garden_madam/mqtt.dart';
import 'package:mqtt_client/mqtt_client.dart';

import 'butler_detail_image_composition.dart';
import 'butler_page_wrapper.dart';

class OverviewPageWrapper extends StatelessWidget {
  final MqttConfig mqttConfig;
  final MqttClient mqttClient;

  const OverviewPageWrapper({Key key, this.mqttConfig, this.mqttClient})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Buttlers"),
      ),
      body: butlerCard(context),
    );
  }

  Widget butlerCard(BuildContext context) {
    var butlerId = "local";
    var butlerName = "Virtueller Dev Buttler";
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
      height: 350,
      child: Card(
        elevation: 1,
        child: InkWell(
          onTap: () => _navigateToButlerPage(context, butlerId, butlerName),
          child: Column(
            children: <Widget>[
              ButlerDetailImageComposition(
                  butler: Butler(butlerId, butlerName)),
              Text(
                butlerName,
                textScaleFactor: 2,
              )
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToButlerPage(
      BuildContext context, String butlerId, String butlerName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext newContext) {
          return new ButlerPageWrapper(
            butlerId: butlerId,
            butlerName: butlerName,
            mqttConfig: mqttConfig,
            mqttClient: mqttClient,
          );
        },
      ),
    );
  }
}
