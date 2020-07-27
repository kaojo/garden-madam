abstract class SettingsEvent {
  const SettingsEvent();
}

class SettingsReloadEvent extends SettingsEvent {}

class SettingsLoadedEvent extends SettingsEvent {}

class SettingsLoadErrorEvent extends SettingsEvent {
  final String errorMessage;

  const SettingsLoadErrorEvent(this.errorMessage);
}

class InvalidMqttSettingsEvent extends SettingsEvent {}

class DeleteButlerEvent extends SettingsEvent {
  final String id;

  DeleteButlerEvent(this.id);
}
