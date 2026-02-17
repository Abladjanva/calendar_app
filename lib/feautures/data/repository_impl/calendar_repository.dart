import 'package:calendar_app/data/data_range.dart';
import 'package:calendar_app/feautures/domain/repository/calendar_repository.dart';
import 'package:intl/intl.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');

  @override
  bool validateDateFormat(String dateString) {
    if (dateString.length != 10) return false;
    
    final parts = dateString.split('.');
    if (parts.length != 3) return false;
    
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    
    if (day == null || month == null || year == null) return false;
    if (day < 1 || day > 31) return false;
    if (month < 1 || month > 12) return false;
    if (year < 1000 || year > 9999) return false;
    
    try {
      final date = DateTime(year, month, day);
      return date.day == day && date.month == month && date.year == year;
    } catch (e) {
      return false;
    }
  }

  @override
  DateTime? parseDate(String dateString) {
    try {
      if (!validateDateFormat(dateString)) return null;
      return _dateFormat.parseStrict(dateString);
    } catch (e) {
      return null;
    }
  }

  @override
  String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  @override
  bool isDateInRange(DateTime date, DateTime minDate, DateTime maxDate) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final minOnly = DateTime(minDate.year, minDate.month, minDate.day);
    final maxOnly = DateTime(maxDate.year, maxDate.month, maxDate.day);
    
    return (dateOnly.isAtSameMomentAs(minOnly) || dateOnly.isAfter(minOnly)) &&
           (dateOnly.isAtSameMomentAs(maxOnly) || dateOnly.isBefore(maxOnly));
  }

  @override
  DateTime getCurrentDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  DateRange normalizeDateRange(DateRange range) {
    return range.normalize();
  }
}