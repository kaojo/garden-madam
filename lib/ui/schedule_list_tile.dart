import 'package:flutter/material.dart';
import 'package:garden_madam/models/models.dart';

class ScheduleListTile extends StatelessWidget {
  final Schedule schedule;

  const ScheduleListTile({Key key, this.schedule}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Switch(
        value: schedule.enabled,
        onChanged: (bool newValue) {
          // Toggle Schedule enabled flag
        },
      ),
      title: Text(formatScheduleTimes(context)),
      trailing: IconButton(
        icon: Icon(Icons.delete, color: Colors.grey),
        onPressed: () {
          // delete schedule
        },
      ),
    );
  }

  String formatScheduleTimes(BuildContext context) {
    var start = schedule.startTime != null
        ? schedule.startTime.format(context)
        : "Start";
    var end =
        schedule.endTime != null ? schedule.endTime.format(context) : "End";
    return "$start -> $end";
  }

  String formatTime(BuildContext context, TimeOfDay time) {
    return time != null ? time.format(context) : "NA";
  }
}
