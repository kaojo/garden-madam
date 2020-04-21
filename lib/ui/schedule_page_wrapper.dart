import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garden_madam/blocs/blocs.dart';
import 'package:garden_madam/models/models.dart';
import 'package:garden_madam/repositories/schedule_repository.dart';
import 'package:garden_madam/ui/schedule_page.dart';

class SchedulePageWrapper extends StatelessWidget {
  final Pin pin;
  final ButlerBloc butlerBloc;

  const SchedulePageWrapper({Key key, this.pin, this.butlerBloc})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var scheduleRepository = new ScheduleRepository();
    return RepositoryProvider(
      builder: (context) {
        return scheduleRepository;
      },
      child: BlocProvider.value(
        value: butlerBloc,
        child: BlocProvider.value(
          value: ScheduleBloc(scheduleRepository),
          child: SchedulePage(
            pin: pin,
          ),
        ),
      ),
    );
  }
}
