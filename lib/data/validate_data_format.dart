import 'package:calendar_app/data/use_cases.dart';
import 'package:calendar_app/feautures/domain/repository/calendar_repository.dart';

class ValidateDateFormat implements UseCase<bool, String> {
  final CalendarRepository repository;

  ValidateDateFormat(this.repository);

  @override
  bool call(String dateString) {
    return repository.validateDateFormat(dateString);
  }
}
