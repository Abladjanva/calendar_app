import 'package:calendar_app/data/calendar_mode.dart';
import 'package:calendar_app/data/data_range.dart';
import 'package:calendar_app/feautures/data/bloc/bloc/calendar_bloc.dart';
import 'package:calendar_app/feautures/data/bloc/event/calendar_event.dart';
import 'package:calendar_app/feautures/data/bloc/state/calendar_state.dart';
import 'package:calendar_app/feautures/presentation/calendar_widgets/data_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'calendar_header.dart';
import 'calendar_grid.dart';

class CalendarPicker extends StatelessWidget {
  final CalendarMode mode;
  final DateTime minDate;
  final DateTime maxDate;
  final DateRange? initialRange;
  final Function(DateRange)? onDateChanged;
  final List<DateTime>? excludedDates;
  final TextAlign textAlign;

  const CalendarPicker({
    Key? key,
    this.mode = CalendarMode.single,
    required this.minDate,
    required this.maxDate,
    this.initialRange,
    this.onDateChanged,
    this.excludedDates,
    this.textAlign = TextAlign.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CalendarHeader(),
              const SizedBox(height: 16),
              CalendarGrid(excludedDates: excludedDates),
              const SizedBox(height: 24),
              _buildInputFields(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputFields(BuildContext context, CalendarState state) {
    final bloc = context.read<CalendarBloc>();

    if (state.mode == CalendarMode.single) {
      final value = state.selectedRange.startDate != null
          ? _fmt(state.selectedRange.startDate!)
          : null;
      final isToday = _isToday(state.selectedRange.startDate);

      return DateInputField(
        key: const ValueKey('single'),
         hint: '00.00.0000',
        initialValue: value,
        isToday: isToday,
        minDate: minDate,
        maxDate: maxDate,
        excludedDates: excludedDates,
        textAlign: textAlign,
        onDateChanged: (v) =>
            bloc.add(UpdateDateFromInput(dateString: v, isStartDate: true)),
      );
    }

    final normalized = state.selectedRange.normalize();
    final isStartToday = _isToday(normalized.startDate);
    final isEndToday = _isToday(normalized.endDate);

    return Row(
      key: const ValueKey('range_two_always'),
      children: [
        Expanded(
          child: DateInputField(
            key: const ValueKey('from'),
            hint: '00.00.0000',
            initialValue: normalized.startDate != null
                ? _fmt(normalized.startDate!)
                : null,
            isToday: isStartToday,
            minDate: minDate,
            maxDate: maxDate,
            excludedDates: excludedDates,
            textAlign: textAlign, 
            onDateChanged: (v) =>
                bloc.add(UpdateDateFromInput(dateString: v, isStartDate: true)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DateInputField(
            key: const ValueKey('to'),
            hint: '00.00.0000',
            initialValue: normalized.endDate != null
                ? _fmt(normalized.endDate!)
                : null,
            isToday: isEndToday,
            minDate: minDate,
            maxDate: maxDate,
            excludedDates: excludedDates,
            isEndField: true,
            startDate: normalized.startDate,
            textAlign: textAlign, 
            onDateChanged: (v) =>
                bloc.add(UpdateDateFromInput(dateString: v, isStartDate: false)),
          ),
        ),
      ],
    );
  }

  bool _isToday(DateTime? date) {
    if (date == null) return true;
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}