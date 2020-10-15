import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:garden_madam/blocs/blocs.dart';
import 'package:garden_madam/repositories/settings_repository.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _settingsRepository;

  SettingsBloc(this._settingsRepository)
      : assert(_settingsRepository != null),
        super(SettingsLoading());

  Future<void> init() async {
    try {
      var event = await _settingsRepository.init();
      add(event);
    } catch (error, s) {
      log(error.toString(), error: error, stackTrace: s);
      add(SettingsLoadErrorEvent(error.toString()));
    }
  }

  @override
  Stream<SettingsState> mapEventToState(SettingsEvent event) async* {
    if (event is SettingsReloadEvent) {
      yield SettingsLoading();
      yield await this._settingsRepository.reload();
    } else if (event is SettingsLoadedEvent) {
      yield this._settingsRepository.settingsState();
    } else if (event is SettingsLoadErrorEvent) {
      yield new SettingsError(event.errorMessage);
    } else if (event is InvalidMqttSettingsEvent) {
      yield InvalidMqttSettings();
    } else if (event is DeleteButlerEvent) {
      yield SettingsLoading();
      yield await this._settingsRepository.deleteButler(event.id);
    }
  }
}
