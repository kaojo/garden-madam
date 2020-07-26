import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:garden_madam/datahandlers/datahandlers.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../models/butler.dart';
import '../models/mqtt.dart';
import '../models/pin.dart';
import '../models/schedule.dart';

class ButlerRepository {
  Butler _butler;
  final MqttClient mqttClient;
  final MqttConfig mqttConfig;
  final ButlerHealthStatusMqttClient _butlerHealthStatusMqttClient;
  final ButlerLayoutStatusMqttClient _butlerLayoutStatusMqttClient;
  final ButlerWateringScheduleStatusMqttClient
      _butlerWateringScheduleStatusMqttClient;
  final StreamController<Butler> _butlerUpdated = StreamController();

  ButlerRepository({
    @required this.mqttConfig,
    @required this.mqttClient,
  })  : _butlerHealthStatusMqttClient =
            ButlerHealthStatusMqttClient(mqttClient: mqttClient),
        _butlerLayoutStatusMqttClient =
            ButlerLayoutStatusMqttClient(mqttClient: mqttClient),
        _butlerWateringScheduleStatusMqttClient =
            ButlerWateringScheduleStatusMqttClient(mqttClient: mqttClient);

  void connect(Butler butler) {
    this._butler = butler;
    _connect();
  }

  Future<void> refresh() async {
    await _refresh();
  }

  Future<Butler> getButler() async {
    return _butler;
  }

  Future<Butler> turnOffWithRetry(Pin pin) async {
    try {
      await doTurnOff(pin).catchError((error) async {
        log("Could not turn off valve " + pin.displayName(), error: error);
        await _refresh().then((_) {
          return doTurnOff(pin);
        });
      });
    } catch (e) {
      log("Could not turn off valve " + pin.displayName(), error: e);
      throw new ButlerInteractionError(_butler);
    }
    return _butler;
  }

  Future<Butler> turnOnWithRetry(Pin pin) async {
    log("turn on with retry");
    try {
      try {
        await doTurnOn(pin);
      } catch (e) {
        log("Could not turn on valve " + pin.displayName(), error: e);
        await _refresh();
        await doTurnOn(pin);
      }
    } catch (e) {
      log("Could not turn on valve " + pin.displayName(), error: e);
      throw new ButlerInteractionError(_butler);
    }
    return _butler;
  }

  Future<Butler> doTurnOff(Pin pin) async {
    await this
        ._butlerLayoutStatusMqttClient
        .turnOff(this._butler.id, pin.valvePinNumber)
        .then((_) => pin.turnOff());
    return _butler;
  }

  Future<Butler> doTurnOn(Pin pin) async {
    await this
        ._butlerLayoutStatusMqttClient
        .turnOn(this._butler.id, pin.valvePinNumber)
        .then((_) => pin.turnOn());
    return _butler;
  }

  Future<Butler> toggleSchedule(Schedule schedule) async {
    MqttValveSchedule mqttSchedule = mapToMqttValveSchedule(schedule);
    if (schedule.enabled) {
      await this
          ._butlerWateringScheduleStatusMqttClient
          .disableSchedule(this._butler.id, mqttSchedule)
          .then((_) => schedule.disable());
    } else {
      await this
          ._butlerWateringScheduleStatusMqttClient
          .enableSchedule(this._butler.id, mqttSchedule)
          .then((_) => schedule.enable());
    }
    return _butler;
  }

  Future<Butler> deleteSchedule(Schedule schedule) async {
    MqttValveSchedule mqttSchedule = mapToMqttValveSchedule(schedule);
    await this
        ._butlerWateringScheduleStatusMqttClient
        .deleteSchedule(this._butler.id, mqttSchedule)
        .then((_) =>
            this._butler.findPin(schedule.valvePin).removeSchedule(schedule));

    return _butler;
  }

  Future<Butler> createSchedule(Schedule schedule) async {
    MqttValveSchedule mqttSchedule = mapToMqttValveSchedule(schedule);
    await this
        ._butlerWateringScheduleStatusMqttClient
        .createSchedule(this._butler.id, mqttSchedule)
        .then((_) =>
            this._butler.findPin(schedule.valvePin).addSchedule(schedule));

    return _butler;
  }

  Future<void> _refresh() async {
    log('refresh');
    await _connect();
  }

  Future<void> _subscribeToButlerStatusStreams(
      MqttClientConnectionStatus status) async {
    if (_mqttClientIsConnected(status)) {
      this
          ._butlerLayoutStatusMqttClient
          .getLayoutStatus(this._butler.id)
          .forEach(_updateFromLayoutStatus);

      this
          ._butlerWateringScheduleStatusMqttClient
          .getWateringScheduleStatus(this._butler.id)
          .forEach(_updateFromScheduleStatus);

      this
          ._butlerHealthStatusMqttClient
          .getHealthStatus(this._butler.id)
          .forEach(_updateFromHealthStatus);
    } else {
      log('Error detected. Subscription to mqtt topics attempted on a invalid connection.');
      log('$status');
      if (status != null) log('${status.state}');
      log(this.mqttClient.connectionStatus.returnCode.toString());
    }
  }

  bool _mqttClientIsConnected(MqttClientConnectionStatus status) =>
      status != null && status.state == MqttConnectionState.connected;

  void _updateFromHealthStatus(MqttHealthStatus status) {
    if (status == MqttHealthStatus.online) {
      this._butler.online = true;
    } else {
      this._butler.online = false;
    }
    _butlerWasUpdated();
  }

  void _updateFromScheduleStatus(MqttWateringSchedule status) {
    for (var schedule in status.schedules) {
      var pin = this._butler.findPin(schedule.valve);
      if (pin == null) {
        pin = Pin(schedule.valve);
        this._butler.addPin(pin);
      }

      TimeOfDay startTime = _getStartTime(schedule.schedule);
      TimeOfDay endTime = _getEndTime(schedule.schedule);
      if (startTime != null && endTime != null) {
        pin.addSchedule(Schedule(pin.valvePinNumber, startTime, endTime,
            enabled: schedule.enabled));
      }
    }
    _butlerWasUpdated();
  }

  void _updateFromLayoutStatus(MqttLayoutStatus status) {
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
          log('unknown valve status found');
          status = Status.OFF;
          break;
      }
      pin.status = status;
    }
    _butlerWasUpdated();
  }

  void _butlerWasUpdated() {
    _butlerUpdated.add(_butler);
  }

  Future<void> _connect() async {
    log('Starting connection to mqtt server.');

    if (_mqttClientIsConnected(this.mqttClient.connectionStatus)) {
      log('mqtt client connected');
      await _subscribeToButlerStatusStreams(this.mqttClient.connectionStatus);
    } else {
      log('mqtt client not connected');
      await this
          .mqttClient
          .connect(mqttConfig.username, mqttConfig.password)
          .then(_subscribeToButlerStatusStreams);
    }
  }

  Stream<Butler> butlerUpdatedStream() {
    return _butlerUpdated.stream;
  }

  TimeOfDay _getStartTime(MqttSchedule schedule) {
    return _getTime(schedule.start_hour, schedule.start_minute);
  }

  TimeOfDay _getEndTime(MqttSchedule schedule) {
    return _getTime(schedule.end_hour, schedule.end_minute);
  }

  TimeOfDay _getTime(int hour, int minute) {
    if (hour != null && minute != null) {
      return TimeOfDay(hour: hour, minute: minute);
    }
    return null;
  }

  MqttValveSchedule mapToMqttValveSchedule(Schedule schedule) {
    return MqttValveSchedule(
        schedule.valvePin,
        MqttSchedule(schedule.startTime.hour, schedule.startTime.minute,
            schedule.endTime.hour, schedule.endTime.minute),
        schedule.enabled);
  }

  void close() {
    // set autoRreconnect to false because otherwise an error would be thrown here: package:mqtt_client/src/mqtt_client.dart:327:30
    this.mqttClient.autoReconnect = false;
    this.mqttClient.disconnect();
  }
}

class ButlerInteractionError extends Error {
  final Butler butler;

  ButlerInteractionError(this.butler);
}
