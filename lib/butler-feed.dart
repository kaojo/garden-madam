import 'dart:async';
import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';

import 'model.dart';
import 'mqtt.dart';

class ButlerFeed {
  StreamController<Butler> _streamController = StreamController<Butler>();
  Butler _butler;
  MqttClient _mqttClient;

  MqttLayoutStatus _mqttLayoutStatus;
  MqttWateringSchedule _mqttWateringScheduleStatus;

  ButlerFeed(String id, String name, MqttConfig mqttConfig) {
    this._butler = Butler(id, name);
    this._mqttClient = MqttClient.withPort(
        mqttConfig.hostname, mqttConfig.client_id, mqttConfig.port);
    this._mqttClient.secure = true;
    this._mqttClient.onConnected = _onConnected;
    this._mqttClient.onSubscribed = _onSubscribed;
    this
        ._mqttClient
        .connect(mqttConfig.username, mqttConfig.password)
        .then(subscribeToButlerStatusStreams);
  }

  Stream<Butler> get stream {
    return _streamController.stream;
  }

  String get _layoutStatusTopic {
    return this._butler.id + '/garden-butler/status/layout';
  }

  String get _wateringScheduleStatusTopic {
    return this._butler.id + '/garden-butler/status/watering-schedule';
  }

  String get _layoutConfigStatusTopic {
    return this._butler.id + '/garden-butler/status/layout-config';
  }

  /// The successful connect callback
  void _onConnected() {
    print("connected successful");
  }

  /// The subscribed callback
  void _onSubscribed(String topic) {
    print('Subscription confirmed for topic $topic');
  }

  Future subscribeToButlerStatusStreams(_) async {
    print(_layoutStatusTopic);
    this._mqttClient.subscribe(_layoutStatusTopic, MqttQos.exactlyOnce);
    this
        ._mqttClient
        .subscribe(_wateringScheduleStatusTopic, MqttQos.exactlyOnce);

    this._mqttClient.updates.listen(onStatusMessageReceived);
  }

  void onStatusMessageReceived(List<MqttReceivedMessage<MqttMessage>> event) {
    for (var messageWrapper in event) {
      if (messageWrapper.topic == _layoutStatusTopic) {
        MqttPublishMessage publishMessage = messageWrapper.payload;
        var payload = MqttPublishPayload.bytesToStringAsString(
            publishMessage.payload.message);
        print(payload);

        this._mqttLayoutStatus =
            MqttLayoutStatus.fromJson(json.decode(payload));
      }
      if (messageWrapper.topic == _wateringScheduleStatusTopic) {
        MqttPublishMessage publishMessage = messageWrapper.payload;
        var payload = MqttPublishPayload.bytesToStringAsString(
            publishMessage.payload.message);
        print(payload);

        this._mqttWateringScheduleStatus =
            MqttWateringSchedule.fromJson(json.decode(payload));
      }
      _updateButler();
    }
  }

  void _updateButler() {
    for (var valve in this._mqttLayoutStatus.valves) {
      var pin = this._butler.findPin(valve.valve_pin_number);
      if (pin == null) {
        pin = Pin(valve.valve_pin_number);
        this._butler.addPin(pin);
      }
      var status;
      switch (valve.status) {
        case MqttValveStatus.OPEN:
          status = Status.ON;
          break;
        case MqttValveStatus.CLOSED:
          status = Status.OFF;
          break;
        case MqttValveStatus.UNKNOWN:
          print('unknown valve status found');
          status = Status.OFF;
          break;
      }
      pin.status = status;
    }

    this._streamController.add(this._butler);
  }
}