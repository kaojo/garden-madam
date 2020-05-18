import 'dart:developer';

import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:garden_madam/repositories/settings_repository.dart';

class SettingsFormBloc extends FormBloc<String, String> {
  final hostname = TextFieldBloc(
    // ignore: close_sinks
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final port = TextFieldBloc(
    // ignore: close_sinks
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final username = TextFieldBloc(); // ignore: close_sinks

  final password = TextFieldBloc(); // ignore: close_sinks

  SettingsRepository settingsRepository;

  SettingsFormBloc(SettingsRepository this.settingsRepository)
      : super(isLoading: true) {
    addFieldBlocs(
      fieldBlocs: [hostname, port, username, password],
    );
  }

  @override
  void onLoading() async {
    try {
      var mqttConfig = await settingsRepository.mqttConfig();
      hostname.updateInitialValue(mqttConfig.hostname);
      port.updateInitialValue(
          mqttConfig.port != null ? mqttConfig.port.toString() : null);
      username.updateInitialValue(mqttConfig.username);
      password.updateInitialValue(mqttConfig.password);
      emitLoaded();
    } catch (e) {
      log(e.runtimeType.toString());
      log(e.toString());
      log(e.stackTrace.toString());
      emitLoadFailed();
    }
  }

  @override
  void onSubmitting() async {
    await Future<void>.delayed(Duration(seconds: 1));

    if (hostname.value != null && port.value != null) {
      try {
        await settingsRepository.save(
            hostname.value, port.valueToInt, username.value, password.value);
      } catch (e) {
        emitFailure(failureResponse: 'Error saving mqtt settings!');
      }
      emitSuccess();
    } else {
      emitFailure(failureResponse: 'This is an awesome error!');
    }
  }
}
