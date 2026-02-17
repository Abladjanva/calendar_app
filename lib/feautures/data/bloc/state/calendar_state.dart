import 'package:calendar_app/data/calendar_mode.dart';
import 'package:calendar_app/data/data_range.dart';
import 'package:equatable/equatable.dart';

class CalendarState extends Equatable {
  final CalendarMode mode;
  final DateTime displayedMonth;
  final DateRange selectedRange;
  final DateTime minDate;
  final DateTime maxDate;
  final DateTime? hoverDate;
  final String? errorMessage;

  const CalendarState({
    required this.mode,
    required this.displayedMonth,
    required this.selectedRange,
    required this.minDate,
    required this.maxDate,
    this.hoverDate,
    this.errorMessage,
  });

  factory CalendarState.initial() {
    final now = DateTime.now();
    return CalendarState(
      mode: CalendarMode.single,
      displayedMonth: DateTime(now.year, now.month, 1),
      selectedRange: const DateRange(),
      minDate: DateTime(2020, 1, 1),
      maxDate: DateTime(2030, 12, 31),
      hoverDate: null,
      errorMessage: null,
    );
  }

  CalendarState copyWith({
    CalendarMode? mode,
    DateTime? displayedMonth,
    DateRange? selectedRange,
    DateTime? minDate,
    DateTime? maxDate,
    DateTime? hoverDate,
    String? errorMessage,
    bool clearHover = false,
    bool clearError = false,
  }) {
    return CalendarState(
      mode: mode ?? this.mode,
      displayedMonth: displayedMonth ?? this.displayedMonth,
      selectedRange: selectedRange ?? this.selectedRange,
      minDate: minDate ?? this.minDate,
      maxDate: maxDate ?? this.maxDate,
      hoverDate: clearHover ? null : (hoverDate ?? this.hoverDate),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        mode,
        displayedMonth,
        selectedRange,
        minDate,
        maxDate,
        hoverDate,
        errorMessage,
      ];
}