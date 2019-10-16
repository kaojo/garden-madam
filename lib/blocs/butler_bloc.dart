import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:garden_madam/models/models.dart';
import 'package:garden_madam/repositories/butler_repository.dart';

import 'butler_event.dart';
import 'butler_state.dart';

class ButlerBloc extends Bloc<ButlerEvent, ButlerState> {
  final ButlerRepository butlerRepository;

  ButlerBloc({@required this.butlerRepository})
      : assert(butlerRepository != null);

  @override
  ButlerState get initialState => ButlerEmpty();

  @override
  Stream<ButlerState> mapEventToState(ButlerEvent event) async* {
    if (event is FetchButler) {
      yield ButlerLoading();
      try {
        final Butler butler = await butlerRepository.getButler();
        if (butler == null) {
          yield ButlerEmpty();
        } else {
          yield ButlerLoaded(butler: butler);
        }
      } catch (_) {
        yield ButlerError();
      }
    }
  }
}