import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:garden_madam/blocs/blocs.dart';
import 'package:garden_madam/repositories/settings_repository.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _settingsRepository;

  SettingsBloc(this._settingsRepository) : assert(_settingsRepository != null);

  @override
  SettingsState get initialState {
    _settingsRepository.init().then(
      (event) {
        add(event);
      },
      onError: (error) {
        log(error.toString());
        add(SettingsLoadErrorEvent());
      },
    );
    return SettingsLoading();
  }

  @override
  Stream<SettingsState> mapEventToState(SettingsEvent event) async* {
    if (event is SettingsReloadEvent) {
      yield this._settingsRepository.reload();
    } else if (event is SettingsLoadedEvent) {
      yield this._settingsRepository.settingsState();
    } else if (event is SettingsLoadErrorEvent) {
      yield new SettingsError();
    } else if (event is InvalidMqttSettingsEvent) {
      yield InvalidMqttSettings();
    }
  }
}
