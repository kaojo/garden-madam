import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garden_madam/blocs/blocs.dart';
import 'package:garden_madam/models/models.dart';

class ScheduleSwitch extends StatelessWidget {
  final Schedule _schedule;

  ScheduleSwitch(this._schedule);

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _schedule.enabled,
      onChanged: (newValue) => togglePin(context, _schedule, newValue),
    );
  }

  togglePin(BuildContext context, Schedule schedule, bool newValue) {
    try {
      ToggleScheduleEvent toggleValveEvent = _createToggleEvent(schedule);
      _dispatchEvent(context, toggleValveEvent);
    } on Exception catch (e) {
      _handleToggleError(context, _schedule, newValue, e);
    }
  }

  ToggleScheduleEvent _createToggleEvent(Schedule schedule) {
    return ToggleScheduleEvent(schedule);
  }

  void _dispatchEvent(BuildContext context, ButlerEvent event) {
    BlocProvider.of<ButlerBloc>(context).add(event);
  }

  void _handleToggleError(
      BuildContext context, Schedule schedule, bool newValue, Exception e) {
    log(e.toString());
    _restoreOldScheduleStatus(schedule, newValue);
    _displayErrorDialog(context);
  }

  void _displayErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Connection Error"),
          content: new Text("Could not reach your butler. Try again later."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _restoreOldScheduleStatus(Schedule schedule, bool newValue) {
    schedule.enabled = !newValue;
  }
}
