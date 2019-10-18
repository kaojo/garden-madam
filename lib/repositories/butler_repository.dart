import 'dart:async';

import 'package:garden_madam/datahandlers/datahandlers.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../models/butler.dart';
import '../models/pin.dart';
import '../models/schedule.dart';
import '../mqtt.dart';

class ButlerRepository {
  Butler _butler;
  final MqttClient mqttClient;
  final MqttConfig mqttConfig;
  final ButlerHealthStatusMqttClient butlerHealthStatusMqttClient;
  final ButlerLayoutStatusMqttClient butlerLayoutStatusMqttClient;
  final ButlerWateringScheduleStatusMqttClient
      butlerWateringScheduleStatusMqttClient;

  ButlerRepository(
      {this.mqttConfig,
      this.mqttClient,
      this.butlerHealthStatusMqttClient,
      this.butlerLayoutStatusMqttClient,
      this.butlerWateringScheduleStatusMqttClient}) {
    this.mqttClient.secure = true;
    this.mqttClient.onConnected = _onConnected;
    this.mqttClient.onSubscribed = _onSubscribed;
  }

  void connect(Butler butler) {
    this._butler = butler;
    _connect();
  }

  Future<Butler> getButler() async {
    return _butler;
  }

  Future<Butler> turnOffWithRetry(Pin pin) async {
    await doTurnOff(pin).catchError((error) {
      print(error);
      refresh().then((_) {
        return doTurnOff(pin)
            .catchError((error) => print("TODO: handle retry error"));
      });
    });
    return _butler;
  }

  Future<Butler> turnOnWithRetry(Pin pin) async {
    await doTurnOn(pin).catchError((error) {
      print(error);
      refresh().then((_) {
        return doTurnOn(pin)
            .catchError((error) => print("TODO: handle retry error"));
      });
    });
    return _butler;
  }

  Future<Butler> doTurnOff(Pin pin) async {
    await this
        .butlerLayoutStatusMqttClient
        .turnOff(this._butler.id, pin.valvePinNumber)
        .then((_) => pin.turnOff());
    return _butler;
  }

  Future<Butler> doTurnOn(Pin pin) async {
    await this
        .butlerLayoutStatusMqttClient
        .turnOn(this._butler.id, pin.valvePinNumber)
        .then((_) => pin.turnOn());
    return _butler;
  }

  void _onConnected() {
    print("connected successful");
  }

  void _onSubscribed(String topic) {
    print('Subscription confirmed for topic $topic');
  }

  Future subscribeToButlerStatusStreams(
      MqttClientConnectionStatus status) async {
    if (_mqttClientIsConnected(status)) {
      this
          .butlerLayoutStatusMqttClient
          .getLayoutStatus(this._butler.id)
          .forEach(_updateFromLayoutStatus);

      this
          .butlerWateringScheduleStatusMqttClient
          .getWateringScheduleStatus(this._butler.id)
          .forEach(_updateFromScheduleStatus);

      this
          .butlerHealthStatusMqttClient
          .getHealthStatus(this._butler.id)
          .forEach(_updateFromHealthStatus);
    } else {
      print('Error detected. Subscription to mqtt topics attempted on a invalid connection.');
      print('$status');
      if (status != null) print('${status.state}');
      print(this.mqttClient.connectionStatus.returnCode);
    }
  }

  bool _mqttClientIsConnected(MqttClientConnectionStatus status) => status != null && status.state == MqttConnectionState.connected;

  void _updateFromHealthStatus(status) {
    if (status == MqttHealthStatus.online) {
      this._butler.online = true;
    } else {
      this._butler.online = false;
    }
  }

  void _updateFromScheduleStatus(status) {
    for (var schedule in status.schedules) {
      var pin = this._butler.findPin(schedule.valve);
      if (pin == null) {
        pin = Pin(schedule.valve);
        this._butler.addPin(pin);
      }

      var cronExpression = schedule.schedule.cron_expression;
      var durationSeconds = schedule.schedule.duration_seconds;
      if (cronExpression != null && durationSeconds != null) {
        pin.schedule =
            Schedule(cronExpression, durationSeconds, enabled: status.enabled);
      }
    }
  }

  void _updateFromLayoutStatus(status) {
    for (var valve in status.valves) {
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

  Future<void> refresh() async {
    print('refresh');
    if (this.mqttClient.connectionStatus == null ||
        this.mqttClient.connectionStatus.state !=
            MqttConnectionState.connected) {
      print('try reconnect');
      return _connect();
    }
  }

  Future<void> _connect() {
    print('Starting connection to mqtt server.');
    return this
        .mqttClient
        .connect(mqttConfig.username, mqttConfig.password)
        .timeout(Duration(seconds: 5))
        .then(subscribeToButlerStatusStreams);
  }
}
