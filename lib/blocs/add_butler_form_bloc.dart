import 'dart:developer';

import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:garden_madam/blocs/settings_state.dart';
import 'package:garden_madam/repositories/settings_repository.dart';

class AddButlerFormBloc extends FormBloc<ButlerConfig, String> {
  final id = TextFieldBloc(
    // ignore: close_sinks
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final name = TextFieldBloc(
    // ignore: close_sinks
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final SettingsRepository settingsRepository;

  AddButlerFormBloc({this.settingsRepository}) : super(isLoading: false) {
    addFieldBlocs(
      fieldBlocs: [
        id,
        name,
      ],
    );
  }

  @override
  void onSubmitting() async {
    try {
      var butler = ButlerConfig(id: id.value?.trim(), name: name.value?.trim());
      await settingsRepository.saveButler(butler);
      emitSuccess(successResponse: butler);
    } catch (error, stacktrace) {
      log("error", error: error, stackTrace: stacktrace);
      emitFailure(failureResponse: error.toString());
    }
  }
}
