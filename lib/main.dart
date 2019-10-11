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

    var butlerController = ButlerController("local", "Local Development", MqttConfig("mqtt.flespi.io",  8883, "FlespiToken 2PytGtM3gJZWa4JmJy1cDYuTkeZAmubd7xwCP8vVFiFEcdQKBFM2r4JB8wZjOZmM", "","garden_madam_dev"));

    return MaterialApp(
      title: 'Garden Madam',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: StreamBuilder<Butler>(
        stream: butlerController.stream, // a Stream<int> or null
        builder: (BuildContext context, AsyncSnapshot<Butler> snapshot) {
          Widget body;
          Butler butler = null;
          if (snapshot.hasError) body = Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.active:
              butler = snapshot.data;
              body = ButlerDetailsPage(butler, butlerController);
              break;
            default:
              body = new Center(
                child: new CircularProgressIndicator(),
              );
              break;
          }
          return Scaffold(
              appBar: AppBar(
              title: butler != null && butler.name != null ? Text(butler.name) : Text('Loading'),
          ),
          body: body
          );
        },
      ),
    );
  }

}
