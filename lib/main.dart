import 'dart:async';

import 'package:flutter/material.dart';
import 'package:garden_madam/butler-feed.dart';
import 'package:garden_madam/model.dart';
import 'package:garden_madam/mqtt.dart';
import 'package:mqtt_client/mqtt_client.dart';

import 'details/page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var butlerController = ButlerController(
        "local",
        "Local Development",
        MqttConfig(
            "mqtt.flespi.io",
            8883,
            "FlespiToken 2PytGtM3gJZWa4JmJy1cDYuTkeZAmubd7xwCP8vVFiFEcdQKBFM2r4JB8wZjOZmM",
            "",
            "garden_madam_dev"));

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
