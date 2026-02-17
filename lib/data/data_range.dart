import 'package:equatable/equatable.dart';

class DateRange extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;

  const DateRange({this.startDate, this.endDate});

  DateRange normalize() {
    if (startDate == null || endDate == null) {
      return this;
    }

    if (startDate!.isAfter(endDate!)) {
      return DateRange(startDate: endDate, endDate: startDate);
    }

    return this;
  }

  bool contains(DateTime date) {
    if (startDate == null || endDate == null) {
      return false;
    }

    final normalized = normalize();
    final dateOnly = DateTime(date.year, date.month, date.day);
    final start = DateTime(
      normalized.startDate!.year,
      normalized.startDate!.month,
      normalized.startDate!.day,
    );
    final end = DateTime(
      normalized.endDate!.year,
      normalized.endDate!.month,
      normalized.endDate!.day,
    );

    return (dateOnly.isAtSameMomentAs(start) || dateOnly.isAfter(start)) &&
        (dateOnly.isAtSameMomentAs(end) || dateOnly.isBefore(end));
  }

  bool get isComplete => startDate != null && endDate != null;

  bool get isEmpty => startDate == null && endDate == null;

  DateRange copyWith({
    DateTime? startDate,
    DateTime? endDate,
    bool clearStart = false,
    bool clearEnd = false,
  }) {
    return DateRange(
      startDate: clearStart ? null : (startDate ?? this.startDate),
      endDate: clearEnd ? null : (endDate ?? this.endDate),
    );
  }

  @override
  List<Object?> get props => [startDate, endDate];

  @override
  String toString() {
    return 'DateRange(start: $startDate, end: $endDate)';
  }
}
