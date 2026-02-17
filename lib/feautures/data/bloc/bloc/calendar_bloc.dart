import 'package:calendar_app/data/calendar_mode.dart';
import 'package:calendar_app/data/data_range.dart';
import 'package:calendar_app/data/get_current_date.dart';
import 'package:calendar_app/data/parse_date.dart';
import 'package:calendar_app/data/use_cases.dart';
import 'package:calendar_app/data/validate_data_format.dart';
import 'package:calendar_app/feautures/data/bloc/event/calendar_event.dart';
import 'package:calendar_app/feautures/data/bloc/state/calendar_state.dart';
import 'package:calendar_app/feautures/domain/repository/calendar_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final ValidateDateFormat validateDateFormat;
  final ParseDate parseDate;
  final GetCurrentDate getCurrentDate;
  final CalendarRepository repository;
  final Function(DateRange)? onDateChanged;

  CalendarBloc({
    required this.validateDateFormat,
    required this.parseDate,
    required this.getCurrentDate,
    required this.repository,
    this.onDateChanged,
  }) : super(CalendarState.initial()) {
    on<InitializeCalendar>(_onInitializeCalendar);
    on<SelectDate>(_onSelectDate);
    on<UpdateDateFromInput>(_onUpdateDateFromInput);
    on<NavigateToPreviousMonth>(_onNavigateToPreviousMonth);
    on<NavigateToNextMonth>(_onNavigateToNextMonth);
    on<NavigateToPreviousYear>(_onNavigateToPreviousYear);
    on<NavigateToNextYear>(_onNavigateToNextYear);
    on<SelectMonth>(_onSelectMonth);
    on<SetHoverDate>(_onSetHoverDate);
    on<ClearSelection>(_onClearSelection);
  }

  void _onInitializeCalendar(
    InitializeCalendar event,
    Emitter<CalendarState> emit,
  ) {
    DateTime displayMonth;
    
    if (event.initialRange != null && event.initialRange!.endDate != null) {
      final endDate = event.initialRange!.endDate!;
      displayMonth = DateTime(endDate.year, endDate.month, 1);
    } else {
      final today = getCurrentDate(const NoParams());
      displayMonth = DateTime(today.year, today.month, 1);
    }

    emit(CalendarState(
      mode: event.mode,
      displayedMonth: displayMonth,
      selectedRange: event.initialRange ?? const DateRange(),
      minDate: event.minDate,
      maxDate: event.maxDate,
      hoverDate: null,
      errorMessage: null,
    ));
  }

  void _onSelectDate(
    SelectDate event,
    Emitter<CalendarState> emit,
  ) {
    if (!repository.isDateInRange(event.date, state.minDate, state.maxDate)) {
      return;
    }

    DateRange newRange;

    if (state.mode == CalendarMode.single) {
      newRange = DateRange(startDate: event.date, endDate: null);
    } else {
      final currentRange = state.selectedRange;
      
      if (currentRange.startDate != null && 
          _isSameDay(event.date, currentRange.startDate!)) {
        newRange = DateRange(
          startDate: currentRange.endDate,
          endDate: null,
        );
      } else if (currentRange.endDate != null && 
                 _isSameDay(event.date, currentRange.endDate!)) {
        newRange = DateRange(
          startDate: currentRange.startDate,
          endDate: null,
        );
      } else if (currentRange.startDate == null) {
        newRange = DateRange(startDate: event.date, endDate: null);
      } else if (currentRange.endDate == null) {
        newRange = DateRange(
          startDate: currentRange.startDate,
          endDate: event.date,
        ).normalize();
      } else {
        newRange = DateRange(startDate: event.date, endDate: null);
      }
    }

    emit(state.copyWith(
      selectedRange: newRange,
      clearError: true,
    ));

    if (onDateChanged != null && newRange.isComplete) {
      onDateChanged!(newRange.normalize());
    }
  }

  void _onUpdateDateFromInput(
    UpdateDateFromInput event,
    Emitter<CalendarState> emit,
  ) {
    if (!validateDateFormat(event.dateString)) {
      return; 
    }

    final date = parseDate(event.dateString);
    if (date == null) {
      return; 
    }

    if (!repository.isDateInRange(date, state.minDate, state.maxDate)) {
      return; 
    }

    DateRange newRange;
    if (state.mode == CalendarMode.single) {
      newRange = DateRange(startDate: date, endDate: null);
    } else {
      if (event.isStartDate) {
        newRange = DateRange(
          startDate: date,
          endDate: state.selectedRange.endDate,
        );
      } else {
        newRange = DateRange(
          startDate: state.selectedRange.startDate,
          endDate: date,
        );
      }
      newRange = newRange.normalize();
    }

    final newDisplayMonth = DateTime(date.year, date.month, 1);

    emit(state.copyWith(
      selectedRange: newRange,
      displayedMonth: newDisplayMonth,
      clearError: true,
    ));

    if (onDateChanged != null && newRange.isComplete) {
      onDateChanged!(newRange.normalize());
    }
  }

  void _onNavigateToPreviousMonth(
    NavigateToPreviousMonth event,
    Emitter<CalendarState> emit,
  ) {
    final currentMonth = state.displayedMonth;
    DateTime newMonth;
    
    if (currentMonth.month == 1) {
      newMonth = DateTime(currentMonth.year - 1, 12, 1);
    } else {
      newMonth = DateTime(currentMonth.year, currentMonth.month - 1, 1);
    }

    final lastDayOfNewMonth = DateTime(newMonth.year, newMonth.month + 1, 0);
    if (!repository.isDateInRange(lastDayOfNewMonth, state.minDate, state.maxDate)) {
      return; 
    }

    emit(state.copyWith(displayedMonth: newMonth));
  }

  void _onNavigateToNextMonth(
    NavigateToNextMonth event,
    Emitter<CalendarState> emit,
  ) {
    final currentMonth = state.displayedMonth;
    DateTime newMonth;
    
    if (currentMonth.month == 12) {
      newMonth = DateTime(currentMonth.year + 1, 1, 1);
    } else {
      newMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
    }

    if (!repository.isDateInRange(newMonth, state.minDate, state.maxDate)) {
      return; 
    }

    emit(state.copyWith(displayedMonth: newMonth));
  }

  void _onNavigateToPreviousYear(
    NavigateToPreviousYear event,
    Emitter<CalendarState> emit,
  ) {
    final currentMonth = state.displayedMonth;
    final newMonth = DateTime(currentMonth.year - 1, currentMonth.month, 1);

    final lastDayOfNewMonth = DateTime(newMonth.year, newMonth.month + 1, 0);
    if (!repository.isDateInRange(lastDayOfNewMonth, state.minDate, state.maxDate)) {
      return;
    }

    emit(state.copyWith(displayedMonth: newMonth));
  }

  void _onNavigateToNextYear(
    NavigateToNextYear event,
    Emitter<CalendarState> emit,
  ) {
    final currentMonth = state.displayedMonth;
    final newMonth = DateTime(currentMonth.year + 1, currentMonth.month, 1);

    if (!repository.isDateInRange(newMonth, state.minDate, state.maxDate)) {
      return;
    }

    emit(state.copyWith(displayedMonth: newMonth));
  }

  void _onSelectMonth(
    SelectMonth event,
    Emitter<CalendarState> emit,
  ) {
    final newMonth = DateTime(state.displayedMonth.year, event.month, 1);

    final lastDayOfNewMonth = DateTime(newMonth.year, newMonth.month + 1, 0);
    if (!repository.isDateInRange(newMonth, state.minDate, state.maxDate) &&
        !repository.isDateInRange(lastDayOfNewMonth, state.minDate, state.maxDate)) {
      return;
    }

    emit(state.copyWith(displayedMonth: newMonth));
  }

  void _onSetHoverDate(
    SetHoverDate event,
    Emitter<CalendarState> emit,
  ) {
    emit(state.copyWith(
      hoverDate: event.date,
      clearHover: event.date == null,
    ));
  }

  void _onClearSelection(
    ClearSelection event,
    Emitter<CalendarState> emit,
  ) {
    emit(state.copyWith(
      selectedRange: const DateRange(),
      clearError: true,
    ));

    if (onDateChanged != null) {
      onDateChanged!(const DateRange());
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}