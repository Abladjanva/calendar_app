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

  const CalendarPicker({
    Key? key,
    this.mode = CalendarMode.single,
    required this.minDate,
    required this.maxDate,
    this.initialRange,
    this.onDateChanged,
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
              const CalendarGrid(),
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
        label: '',
        initialValue: value,
        isToday: isToday,
        onDateChanged: (v) =>
            bloc.add(UpdateDateFromInput(dateString: v, isStartDate: true)),
      );
    }

    final hasStart = state.selectedRange.startDate != null;
    final hasEnd   = state.selectedRange.endDate != null;
    final normalized = state.selectedRange.normalize();

    if (!hasStart || !hasEnd) {
      final value = hasStart ? _fmt(state.selectedRange.startDate!) : null;
      final isToday = _isToday(state.selectedRange.startDate);

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: DateInputField(
          key: const ValueKey('range_single'),
          label: '',
          initialValue: value,
          isToday: isToday,
          onDateChanged: (v) =>
              bloc.add(UpdateDateFromInput(dateString: v, isStartDate: true)),
        ),
      );
    }

    final isStartToday = _isToday(normalized.startDate);
    final isEndToday   = _isToday(normalized.endDate);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Row(
        key: const ValueKey('range_two'),
        children: [
          Expanded(
            child: DateInputField(
              key: const ValueKey('from'),
              label: '',
              initialValue: _fmt(normalized.startDate!),
              isToday: isStartToday,
              onDateChanged: (v) =>
                  bloc.add(UpdateDateFromInput(dateString: v, isStartDate: true)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DateInputField(
              key: const ValueKey('to'),
              label: '',
              initialValue: _fmt(normalized.endDate!),
              isToday: isEndToday,
              onDateChanged: (v) =>
                  bloc.add(UpdateDateFromInput(dateString: v, isStartDate: false)),
            ),
          ),
        ],
      ),
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