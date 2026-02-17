import 'package:calendar_app/data/data_range.dart';

abstract class CalendarRepository {
  bool validateDateFormat(String dateString);

  DateTime? parseDate(String dateString);

  String formatDate(DateTime date);

  bool isDateInRange(DateTime date, DateTime minDate, DateTime maxDate);

  DateTime getCurrentDate();

  DateRange normalizeDateRange(DateRange range);
}
