

abstract class ButlerEvent {
  const ButlerEvent();
}

class FetchButler extends ButlerEvent {}

class ToggleValve extends ButlerEvent {
  final int pinValveNumber;
  final ToggleDirection toggleDirection;

  ToggleValve(this.pinValveNumber, this.toggleDirection);
}

enum ToggleDirection {
  on,
  off,
}