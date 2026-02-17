import 'package:calendar_app/data/calendar_mode.dart';
import 'package:calendar_app/data/data_range.dart';
import 'package:equatable/equatable.dart';

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => [];
}

class InitializeCalendar extends CalendarEvent {
  final CalendarMode mode;
  final DateTime minDate;
  final DateTime maxDate;
  final DateRange? initialRange;

  const InitializeCalendar({
    required this.mode,
    required this.minDate,
    required this.maxDate,
    this.initialRange,
  });

  @override
  List<Object?> get props => [mode, minDate, maxDate, initialRange];
}

class SelectDate extends CalendarEvent {
  final DateTime date;

  const SelectDate(this.date);

  @override
  List<Object?> get props => [date];
}

class UpdateDateFromInput extends CalendarEvent {
  final String dateString;
  final bool isStartDate;

  const UpdateDateFromInput({
    required this.dateString,
    required this.isStartDate,
  });

  @override
  List<Object?> get props => [dateString, isStartDate];
}

class NavigateToPreviousMonth extends CalendarEvent {
  const NavigateToPreviousMonth();
}

class NavigateToNextMonth extends CalendarEvent {
  const NavigateToNextMonth();
}

class NavigateToPreviousYear extends CalendarEvent {
  const NavigateToPreviousYear();
}

class NavigateToNextYear extends CalendarEvent {
  const NavigateToNextYear();
}

class SelectMonth extends CalendarEvent {
  final int month;

  const SelectMonth(this.month);

  @override
  List<Object?> get props => [month];
}

class SetHoverDate extends CalendarEvent {
  final DateTime? date;

  const SetHoverDate(this.date);

  @override
  List<Object?> get props => [date];
}

class ClearSelection extends CalendarEvent {
  const ClearSelection();
}