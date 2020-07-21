import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garden_madam/blocs/blocs.dart';
import 'package:garden_madam/models/models.dart';

class ScheduleDeleteButton extends StatelessWidget {
  final Schedule _schedule;

  const ScheduleDeleteButton(this._schedule);

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
    DeleteScheduleEvent event = DeleteScheduleEvent(schedule);
    _dispatchEvent(context, event);
  }

  void _dispatchEvent(BuildContext context, ButlerEvent event) {
    BlocProvider.of<ButlerBloc>(context).add(event);
  }
}
