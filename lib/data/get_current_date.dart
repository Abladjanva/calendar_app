import 'package:calendar_app/data/use_cases.dart';
import 'package:calendar_app/feautures/domain/repository/calendar_repository.dart';

class GetCurrentDate implements UseCase<DateTime, NoParams> {
  final CalendarRepository repository;

  GetCurrentDate(this.repository);

  @override
  DateTime call(NoParams params) {
    return repository.getCurrentDate();
  }
}
