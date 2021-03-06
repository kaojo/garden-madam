import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:garden_madam/models/models.dart';
import 'package:garden_madam/repositories/butler_repository.dart';

import 'butler_event.dart';
import 'butler_state.dart';

class ButlerBloc extends Bloc<ButlerEvent, ButlerState> {
  final ButlerRepository butlerRepository;

  StreamSubscription<Butler> subscription;

  ButlerBloc({@required this.butlerRepository})
      : assert(butlerRepository != null),
        super(ButlerEmpty());

  void init() {
    add(LoadButler());
    _refreshButlerOnUpdatesReceived();
  }

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
      } else if (event is ButlerConfigUpdateEvent) {
        Butler butler =
            await butlerRepository.updateButlerConfig(event.butlerConfig);
        yield ButlerLoaded(butler: butler);
      }
    } catch (e) {
      var errorMessage = "Could not perform action" + event.toString();
      log(errorMessage, error: e);
      if (e is ButlerInteractionError) {
        yield ButlerError(errorMessage, butler: e.butler);
      } else {
        yield ButlerError(errorMessage, butler: null);
      }
    }
  }

  void _refreshButlerOnUpdatesReceived() {
    this.subscription = butlerRepository
        .butlerUpdatedStream()
        .listen((_) => add(LoadButler()));
  }

  @override
  Future<void> close() {
    butlerRepository.close();
    subscription.cancel();
    return super.close();
  }
}
