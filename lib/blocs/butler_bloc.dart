import 'dart:developer';

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

  void init() {
    dispatch(LoadButler());
    _refreshButlerOnUpdatesReceived();
  }

  @override
  ButlerState get initialState => ButlerEmpty();

  @override
  Stream<ButlerState> mapEventToState(ButlerEvent event) async* {
    try {
      if (event is LoadButler) {
        yield ButlerLoading();
        final Butler butler = await butlerRepository.getButler();
        if (butler == null) {
          yield ButlerEmpty();
        } else {
          yield ButlerLoaded(butler: butler);
        }
      } else if (event is RefreshButler) {
        final Butler butler = await butlerRepository.getButler();
        if (butler == null) {
          yield ButlerEmpty();
        } else {
          yield ButlerLoaded(butler: butler);
        }
      } else if (event is ToggleValveEvent) {
        Butler butler;
        if (event.toggleDirection == ToggleDirection.on) {
          butler = await butlerRepository.turnOnWithRetry(event.pin);
        } else {
          butler = await butlerRepository.turnOffWithRetry(event.pin);
        }
        yield ButlerLoaded(butler: butler);
      } else if (event is ToggleScheduleEvent) {
        Butler butler = await butlerRepository.toggleSchedule(event.schedule);
        yield ButlerLoaded(butler: butler);
      } else if (event is DeleteScheduleEvent) {
        Butler butler = await butlerRepository.deleteSchedule(event.schedule);
        yield ButlerLoaded(butler: butler);
      } else if (event is CreateScheduleEvent) {
        Butler butler = await butlerRepository.createSchedule(event.schedule);
        yield ButlerLoaded(butler: butler);
      }
    } catch (e) {
      log(e.toString());
      yield ButlerError();
    }
  }

  void _refreshButlerOnUpdatesReceived() {
    butlerRepository
        .butlerUpdatedStream()
        .listen((_) => dispatch(RefreshButler()));
  }
}
