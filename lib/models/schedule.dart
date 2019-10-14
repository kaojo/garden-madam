
class Schedule {
  bool enabled = true;
  String cronExpression;
  int durationSeconds;

  Schedule(this.cronExpression, this.durationSeconds, {this.enabled = true});

}
