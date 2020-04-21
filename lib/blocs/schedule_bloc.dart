import 'package:bloc/bloc.dart';
import 'package:garden_madam/blocs/blocs.dart';
import 'package:garden_madam/repositories/schedule_repository.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final ScheduleRepository _scheduleRepository;

  ScheduleBloc(this._scheduleRepository) : assert(_scheduleRepository != null);

  @override
  ScheduleState get initialState => ScheduleState();

  @override
  Stream<ScheduleState> mapEventToState(ScheduleEvent event) async* {
    if (event is ScheduleStartDateSetEvent) {
      var startTime = event.time;
      _scheduleRepository.startTime = startTime;
      var endTime = _scheduleRepository.endTime;
      yield ScheduleState(startTime: startTime, endTime: endTime);
    } else if (event is ScheduleEndDateSetEvent) {
      var endTime = event.time;
      _scheduleRepository.endTime = endTime;
      var startTime = _scheduleRepository.startTime;
      yield ScheduleState(startTime: startTime, endTime: endTime);
    }
  }
}
