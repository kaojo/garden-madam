import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:garden_madam/blocs/settings_state.dart';
import 'package:garden_madam/models/butler.dart';
import 'package:garden_madam/models/pin.dart';
import 'package:garden_madam/repositories/settings_repository.dart';

class EditButlerFormBloc extends FormBloc<ButlerConfig, String> {
  final butlerId = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final butlerName = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final valves = ListFieldBloc<ValveFieldBloc>(name: "Valves");

  final SettingsRepository settingsRepository;

  final Butler butler;
  final ButlerConfig butlerConfig;

  EditButlerFormBloc({this.settingsRepository, this.butler, this.butlerConfig})
      : super(isLoading: false) {
    butlerId.updateInitialValue(this.butlerConfig.id);
    butlerName.updateInitialValue(this.butlerConfig.name);
    for (Pin pin in this.butler.pins) {
      valves.addFieldBloc(ValveFieldBloc(
        number: TextFieldBloc(
            name: "number", initialValue: pin.valvePinNumber.toString()),
        valveName: TextFieldBloc(name: "valveName", initialValue: pin.name),
      ));
    }
    addFieldBlocs(
      fieldBlocs: [butlerId, butlerName, valves],
    );
  }

  @override
  void onSubmitting() async {
    try {
      List<PinConfig> pinConfigs = [];
      for (var valve in valves.value) {
        pinConfigs.add(PinConfig(
            number: valve.number.valueToInt,
            name: valve.valveName.value?.trim()));
      }

      var butlerConfig = ButlerConfig(
          id: butlerId.value?.trim(),
          name: butlerName.value?.trim(),
          pinConfigs: pinConfigs);
      await settingsRepository.updateButler(butlerConfig);
      emitSuccess(successResponse: butlerConfig);
    } catch (error, stacktrace) {
      log("error", error: error, stackTrace: stacktrace);
      emitFailure(failureResponse: error.toString());
    }
  }
}

class ValveFieldBloc extends GroupFieldBloc {
  final TextFieldBloc number;
  final TextFieldBloc valveName;

  ValveFieldBloc({
    @required this.number,
    @required this.valveName,
    String name,
  }) : super([number, valveName], name: name);
}
