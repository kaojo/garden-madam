import 'dart:async';

import 'package:garden_madam/datahandlers/health_status_mqtt_client.dart';
import 'package:garden_madam/datahandlers/layout_status_handler.dart';
import 'package:garden_madam/datahandlers/schedule_status_handler.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../models/butler.dart';
import '../models/pin.dart';
import '../models/schedule.dart';
import '../datahandlers/mqtt.dart';

class ButlerRepository {
  StreamController<Butler> _streamController = StreamController<Butler>();
  Butler _butler;
  final MqttClient mqttClient;
  final MqttConfig mqttConfig;
  final ButlerHealthStatusMqttClient butlerHealthStatusMqttClient;
  final ButlerLayoutStatusMqttClient butlerLayoutStatusMqttClient;
  final ButlerWateringScheduleStatusMqttClient butlerWateringScheduleStatusMqttClient;

  ButlerRepository({String id, String name, this.mqttConfig, this.mqttClient, this.butlerHealthStatusMqttClient, this.butlerLayoutStatusMqttClient, this.butlerWateringScheduleStatusMqttClient}) {
    this._butler = Butler(id, name);
    this.mqttClient.secure = true;
    this.mqttClient.onConnected = _onConnected;
    this.mqttClient.onSubscribed = _onSubscribed;
    _connect();
  }

  Stream<Butler> get stream {
    return _streamController.stream;
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
      this
          .butlerLayoutStatusMqttClient
          .getLayoutStatus(this._butler.id)
          .forEach((status) {
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
        notifyChanges();
      });

      this
          .butlerWateringScheduleStatusMqttClient
          .getWateringScheduleStatus(this._butler.id)
          .forEach((status) {
        for (var schedule in status.schedules) {
          var pin = this._butler.findPin(schedule.valve);
          if (pin == null) {
            pin = Pin(schedule.valve);
            this._butler.addPin(pin);
          }

          var cronExpression = schedule.schedule.cron_expression;
          var durationSeconds = schedule.schedule.duration_seconds;
          if (cronExpression != null && durationSeconds != null) {
            pin.schedule = Schedule(cronExpression, durationSeconds,
                enabled: status.enabled);
          }
        }
        notifyChanges();
      });

      this
          .butlerHealthStatusMqttClient
          .getHealthStatus(this._butler.id)
          .forEach((status) {
        if (status == MqttHealthStatus.online) {
          this._butler.online = true;
        } else {
          this._butler.online = false;
        }
        notifyChanges();
      });
    } else {
      print('${status}');
      if (status != null) print('${status.state}');
      print(this.mqttClient.connectionStatus.returnCode);
      this
          ._streamController
          .addError("Could not subscribe to butler status topics.");
    }
  }

  void notifyChanges() {
    this._streamController.add(this._butler);
  }

  void turn_off(Pin pin) {
    this.butlerLayoutStatusMqttClient.turnOff(this._butler.id, pin.valvePinNumber);

    pin.status = Status.OFF;
    this.notifyChanges();
  }

  void turn_on(Pin pin) {
    this.butlerLayoutStatusMqttClient.turnOn(this._butler.id, pin.valvePinNumber);

    pin.status = Status.ON;
    this.notifyChanges();
  }


  refresh() async {
    print('refresh');
    if (this.mqttClient.connectionStatus == null ||
        this.mqttClient.connectionStatus.state !=
            MqttConnectionState.connected) {
      print('try reconnect');
      _connect();
    }
    this.notifyChanges();
  }

  void _connect() {
    print('Starting connection to mqtt server.');
    this
        .mqttClient
        .connect(mqttConfig.username, mqttConfig.password)
        .timeout(Duration(seconds: 5))
        .then(subscribeToButlerStatusStreams)
        .catchError((error) {
      print('Could not connect mqtt client: ${error}');
      this._streamController.addError(error);
    });
  }
}
