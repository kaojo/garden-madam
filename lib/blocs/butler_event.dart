

import 'package:garden_madam/models/models.dart';

abstract class ButlerEvent {
  const ButlerEvent();
}

class LoadButler extends ButlerEvent {}
class RefreshButler extends ButlerEvent {}

class ToggleValveEvent extends ButlerEvent {
  final Pin pin;
  final ToggleDirection toggleDirection;

  ToggleValveEvent({this.pin, this.toggleDirection});
}

enum ToggleDirection {
  on,
  off,
}