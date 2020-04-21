import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garden_madam/blocs/blocs.dart';
import 'package:garden_madam/models/models.dart';

class ScheduleDeleteButton extends StatelessWidget {
  final Schedule _schedule;

  ScheduleDeleteButton(this._schedule);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.delete, color: Colors.grey),
      onPressed: () {
        deleteSchedule(context, _schedule);
      },
    );
  }

  deleteSchedule(BuildContext context, Schedule schedule) {
    try {
      DeleteScheduleEvent event = DeleteScheduleEvent(schedule);
      _dispatchEvent(context, event);
    } on Exception catch (e) {
      _handleDeleteError(context, _schedule, e);
    }
  }

  void _dispatchEvent(BuildContext context, ButlerEvent event) {
    var butlerBloc = BlocProvider.of<ButlerBloc>(context);
    butlerBloc.dispatch(event);
  }

  void _handleDeleteError(
      BuildContext context, Schedule schedule, Exception e) {
    log(e.toString());
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
}
