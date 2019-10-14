import 'dart:async';
import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:typed_data/typed_data.dart';

import '../models/butler.dart';
import '../models/pin.dart';
import '../models/schedule.dart';
import '../datahandlers/mqtt.dart';

class ButlerController {
  StreamController<Butler> _streamController = StreamController<Butler>();
  Butler _butler;
  MqttClient _mqttClient;

  MqttLayoutStatus _mqttLayoutStatus;
  MqttWateringSchedule _mqttWateringScheduleStatus;
  String _mqttHealthStatus;
  MqttConfig _mqttConfig;

  ButlerController(String id, String name, this._mqttConfig) {
    this._butler = Butler(id, name);
    this._mqttClient = MqttClient.withPort(
        _mqttConfig.hostname, _mqttConfig.client_id, _mqttConfig.port);
    this._mqttClient.secure = true;
    this._mqttClient.onConnected = _onConnected;
    this._mqttClient.onSubscribed = _onSubscribed;
    _connect();
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

  String get _healthStatusTopic {
    return this._butler.id + '/garden-butler/status/health';
  }

  String get _layoutOpenCommandTopic {
    return this._butler.id + '/garden-butler/command/layout/open';
  }

  String get _layoutCloseCommandTopic {
    return this._butler.id + '/garden-butler/command/layout/close';
  }

  /// The successful connect callback
  void _onConnected() {
    print("connected successful");
  }

  /// The subscribed callback
  void _onSubscribed(String topic) {
    print('Subscription confirmed for topic $topic');
  }

  Future subscribeToButlerStatusStreams(
      MqttClientConnectionStatus status) async {
    if (status != null && status.state == MqttConnectionState.connected) {
      this._mqttClient.subscribe(_layoutStatusTopic, MqttQos.exactlyOnce);
      this
          ._mqttClient
          .subscribe(_wateringScheduleStatusTopic, MqttQos.exactlyOnce);
      this._mqttClient.subscribe(_healthStatusTopic, MqttQos.exactlyOnce);
      this._mqttClient.updates.listen(onStatusMessageReceived,
          onError: (error) {
        print(error);
        this._streamController.addError(error);
      });
    } else {
      print('${status}');
      if (status != null) print('${status.state}');
      print(this._mqttClient.connectionStatus.returnCode);
      this
          ._streamController
          .addError("Could not subscribe to butler status topics.");
    }
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
      if (messageWrapper.topic == _healthStatusTopic) {
        MqttPublishMessage publishMessage = messageWrapper.payload;
        var payload = MqttPublishPayload.bytesToStringAsString(
            publishMessage.payload.message);
        print(payload);

        this._mqttHealthStatus = payload;
      }
      _updateButler();
    }
  }

  void _updateButler() {
    if (this._mqttLayoutStatus != null) {
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
    }
    if (this._mqttWateringScheduleStatus != null) {
      for (var schedule in this._mqttWateringScheduleStatus.schedules) {
        var pin = this._butler.findPin(schedule.valve);
        if (pin == null) {
          pin = Pin(schedule.valve);
          this._butler.addPin(pin);
        }

        var cronExpression = schedule.schedule.cron_expression;
        var durationSeconds = schedule.schedule.duration_seconds;
        if (cronExpression != null && durationSeconds != null) {
          pin.schedule = Schedule(cronExpression, durationSeconds,
              enabled: this._mqttWateringScheduleStatus.enabled);
        }
      }
    }
    if (_mqttHealthStatus != null && _mqttHealthStatus == "ONLINE") {
      this._butler.online = true;
    } else {
      this._butler.online = false;
    }
    this._streamController.add(this._butler);
  }

  void notifyChanges() {
    this._streamController.add(this._butler);
  }

  void turn_off(Pin pin) {
    pin.status = Status.OFF;
    Uint8Buffer buffer = _convertPinNumberToPayload(pin);
    this._mqttClient.publishMessage(
        this._layoutCloseCommandTopic, MqttQos.exactlyOnce, buffer);
    this.notifyChanges();
  }

  void turn_on(Pin pin) {
    pin.status = Status.ON;
    Uint8Buffer buffer = _convertPinNumberToPayload(pin);
    this._mqttClient.publishMessage(
        this._layoutOpenCommandTopic, MqttQos.exactlyOnce, buffer);
    this.notifyChanges();
  }

  Uint8Buffer _convertPinNumberToPayload(Pin pin) {
    var data = utf8.encode(pin.valvePinNumber.toString());
    var buffer = new Uint8Buffer();
    buffer.addAll(data);
    return buffer;
  }

  refresh() async {
    print('refresh');
    if (this._mqttClient.connectionStatus == null ||
        this._mqttClient.connectionStatus.state !=
            MqttConnectionState.connected) {
      print('try reconnect');
      _connect();
    }
    this.notifyChanges();
  }

  void _connect() {
    print('Starting connection to mqtt server.');
    this
        ._mqttClient
        .connect(_mqttConfig.username, _mqttConfig.password)
        .timeout(Duration(seconds: 5))
        .then(subscribeToButlerStatusStreams)
        .catchError((error) {
      print('Could not connect mqtt client: ${error}');
      this._streamController.addError(error);
    });
  }
}
