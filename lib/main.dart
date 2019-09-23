import 'dart:async';

import 'package:flutter/material.dart';
import 'package:garden_madam/butler-feed.dart';
import 'package:garden_madam/model.dart';
import 'package:garden_madam/mqtt.dart';
import 'package:mqtt_client/mqtt_client.dart';

import 'butler-details-page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    var butlerFeed = ButlerFeed("local", "Local Development", MqttConfig("mqtt.flespi.io",  8883, "FlespiToken 2PytGtM3gJZWa4JmJy1cDYuTkeZAmubd7xwCP8vVFiFEcdQKBFM2r4JB8wZjOZmM", "","garden_madam_dev"));

    return MaterialApp(
      title: 'Garden Madam',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: StreamBuilder<Butler>(
        stream: butlerFeed.stream, // a Stream<int> or null
        builder: (BuildContext context, AsyncSnapshot<Butler> snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.active:
              return ButlerDetailsPage(snapshot.data);
            default:
              return Text('Could not load the data to your butler data.');
          }
        },
      ),
    );
  }

}
