abstract class SettingsEvent {
  const SettingsEvent();
}

class SettingsReloadEvent extends SettingsEvent {}

class SettingsLoadedEvent extends SettingsEvent {}

class SettingsLoadErrorEvent extends SettingsEvent {}

class InvalidMqttSettingsEvent extends SettingsEvent {}
