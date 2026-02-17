import 'package:calendar_app/data/use_cases.dart';
import 'package:calendar_app/feautures/domain/repository/calendar_repository.dart';

class ParseDate implements UseCase<DateTime?, String> {
  final CalendarRepository repository;

  ParseDate(this.repository);

  @override
  DateTime? call(String dateString) {
    return repository.parseDate(dateString);
  }
}
