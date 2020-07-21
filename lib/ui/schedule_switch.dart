import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garden_madam/blocs/blocs.dart';
import 'package:garden_madam/models/models.dart';

class ScheduleSwitch extends StatelessWidget {
  final Schedule _schedule;

  const ScheduleSwitch(this._schedule);

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _schedule.enabled,
      onChanged: (newValue) => togglePin(context, _schedule, newValue),
    );
  }

  togglePin(BuildContext context, Schedule schedule, bool newValue) {
    ToggleScheduleEvent toggleValveEvent = _createToggleEvent(schedule);
    _dispatchEvent(context, toggleValveEvent);
  }

  ToggleScheduleEvent _createToggleEvent(Schedule schedule) {
    return ToggleScheduleEvent(schedule);
  }

  void _dispatchEvent(BuildContext context, ButlerEvent event) {
    BlocProvider.of<ButlerBloc>(context).add(event);
  }
}
