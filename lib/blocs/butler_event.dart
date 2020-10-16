import 'package:garden_madam/blocs/settings_state.dart';
import 'package:garden_madam/models/models.dart';

abstract class ButlerEvent {
  const ButlerEvent();
}

class LoadButler extends ButlerEvent {}

class ButlerConfigUpdateEvent extends ButlerEvent {
  final ButlerConfig butlerConfig;

  ButlerConfigUpdateEvent(this.butlerConfig);
}

class ToggleValveEvent extends ButlerEvent {
  final Pin pin;
  final ToggleDirection toggleDirection;

  ToggleValveEvent({this.pin, this.toggleDirection});

  @override
  String toString() {
    return 'ToggleValveEvent{pin: ${pin
        .valvePinNumber}, toggleDirection: $toggleDirection}';
  }
}

enum ToggleDirection {
  on,
  off,
}

class ToggleScheduleEvent extends ButlerEvent {
  final Schedule schedule;

  ToggleScheduleEvent(this.schedule);

  @override
  String toString() {
    return 'ToggleScheduleEvent{schedule: $schedule}';
  }
}

class DeleteScheduleEvent extends ButlerEvent {
  final Schedule schedule;

  DeleteScheduleEvent(this.schedule);

  @override
  String toString() {
    return 'DeleteScheduleEvent{schedule: $schedule}';
  }
}

class CreateScheduleEvent extends ButlerEvent {
  final Schedule schedule;

  CreateScheduleEvent(this.schedule);

  @override
  String toString() {
    return 'CreateScheduleEvent{schedule: $schedule}';
  }
}
