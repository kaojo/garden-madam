import 'package:flutter/material.dart';
import 'package:garden_madam/models/models.dart';
import 'package:garden_madam/ui/schedule_delete_button.dart';
import 'package:garden_madam/ui/schedule_switch.dart';

class ScheduleListTile extends StatelessWidget {
  final Schedule schedule;

  const ScheduleListTile({Key key, this.schedule}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ScheduleSwitch(schedule),
      title: _scheduleTimes(context),
      trailing: ScheduleDeleteButton(schedule),
    );
  }

  Text _scheduleTimes(BuildContext context) =>
      Text(_formatScheduleTimes(context));

  String _formatScheduleTimes(BuildContext context) {
    var start = schedule.startTime != null
        ? schedule.startTime.format(context)
        : "Start";
    var end =
        schedule.endTime != null ? schedule.endTime.format(context) : "End";
    return "$start -> $end";
  }

}
