import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garden_madam/blocs/blocs.dart';
import 'package:garden_madam/models/models.dart';

import 'scaffold.dart';
import 'theme.dart';

class SchedulePage extends StatelessWidget {
  final Pin pin;

  const SchedulePage({Key key, this.pin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      title: "Add schedule for ${pin.displayName()}",
      body: BlocBuilder<ScheduleBloc, ScheduleState>(
        builder: (BuildContext context, ScheduleState scheduleState) {
          return ListView(
            children: <Widget>[
              _startTime(context, scheduleState),
              _endTime(context, scheduleState),
              _addButton(scheduleState, context),
            ],
          );
        },
      ),
    );
  }

  ListTile _addButton(ScheduleState scheduleState, BuildContext context) {
    return ListTile(
      title: RaisedButton(
        onPressed: _isValidSchedule(scheduleState)
            ? () {
                // parse Schedule
                var schedule = _parseSchedule(scheduleState);
                // "Fire add schedule event"
                BlocProvider.of<ButlerBloc>(context)
                    .add(CreateScheduleEvent(schedule));
                // navigate back
                Navigator.of(context).pop();
              }
            : null,
        child: Text("Add"),
        color: _isValidSchedule(scheduleState)
            ? APPBAR_COLOR
            : VALVE_INACTIVE_COLOR,
      ),
    );
  }

  ListTile _endTime(BuildContext context, ScheduleState scheduleState) {
    return ListTile(
      onTap: () => _selectEndTime(context),
      leading: Icon(Icons.stop),
      title: Text("End Time"),
      trailing: _displayTimeOfDay(scheduleState.endTime, context),
    );
  }

  ListTile _startTime(BuildContext context, ScheduleState scheduleState) {
    return ListTile(
      onTap: () => _selectStartTime(context),
      leading: Icon(Icons.play_arrow),
      title: Text("Start Time"),
      trailing: _displayTimeOfDay(scheduleState.startTime, context),
    );
  }

  Text _displayTimeOfDay(TimeOfDay time, BuildContext context) =>
      Text(time != null ? time.format(context) : "-");

  void _selectStartTime(BuildContext context) async {
    TimeOfDay selectedTime = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );
    _dispatchEvent(context, ScheduleStartDateSetEvent(selectedTime));
  }

  void _selectEndTime(BuildContext context) async {
    TimeOfDay selectedTime = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );
    _dispatchEvent(context, ScheduleEndDateSetEvent(selectedTime));
  }

  void _dispatchEvent(BuildContext context, ScheduleEvent event) {
    BlocProvider.of<ScheduleBloc>(context).add(event);
  }

  bool _isValidSchedule(ScheduleState scheduleState) {
    double toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;
    bool isStartBeforeEndTime(double toDouble(TimeOfDay myTime),
            TimeOfDay startTime, TimeOfDay endTime) =>
        toDouble(startTime) < toDouble(endTime);

    var startTime = scheduleState.startTime;
    var endTime = scheduleState.endTime;
    return scheduleState != null &&
        startTime != null &&
        endTime != null &&
        isStartBeforeEndTime(toDouble, startTime, endTime);
  }

  Schedule _parseSchedule(ScheduleState scheduleState) {
    return Schedule(
        pin.valvePinNumber, scheduleState.startTime, scheduleState.endTime,
        enabled: true);
  }
}
