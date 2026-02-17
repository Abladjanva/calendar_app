import 'package:calendar_app/data/data_range.dart';
import 'package:calendar_app/feautures/data/bloc/bloc/calendar_bloc.dart';
import 'package:calendar_app/feautures/data/bloc/event/calendar_event.dart';
import 'package:calendar_app/feautures/data/bloc/state/calendar_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CalendarGrid extends StatelessWidget {
  const CalendarGrid({Key? key}) : super(key: key);

  static const double _rowSpacing = 6.0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (context, state) {
        return Column(
          children: [
            const SizedBox(height: 8),
            _buildCalendarGrid(context, state),
          ],
        );
      },
    );
  }

  Widget _buildCalendarGrid(BuildContext context, CalendarState state) {
    final daysInMonth = _getDaysInMonth(state.displayedMonth);
    final firstWeekday = state.displayedMonth.weekday;

    final List<DateTime?> cells = [];
    for (int i = 1; i < firstWeekday; i++) cells.add(null);
    for (int d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(
        state.displayedMonth.year,
        state.displayedMonth.month,
        d,
      ));
    }
    while (cells.length % 7 != 0) cells.add(null);

    final rowCount = cells.length ~/ 7;

    return Column(
      children: List.generate(rowCount, (rowIndex) {
        final rowCells = cells.sublist(rowIndex * 7, rowIndex * 7 + 7);
        return Padding(
          padding: EdgeInsets.only(
            bottom: rowIndex < rowCount - 1 ? _rowSpacing : 0,
          ),
          child: _buildRow(context, state, rowCells),
        );
      }),
    );
  }

  Widget _buildRow(
    BuildContext context,
    CalendarState state,
    List<DateTime?> rowCells,
  ) {
    return Row(
      children: List.generate(7, (colIndex) {
        final date = rowCells[colIndex];
        if (date == null) return const Expanded(child: SizedBox());
        return Expanded(
          child: AspectRatio(
            aspectRatio: 1.0,
            child: _buildDayCell(context, date, state, colIndex, rowCells),
          ),
        );
      }),
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    DateTime date,
    CalendarState state,
    int colIndex,
    List<DateTime?> rowCells,
  ) {
    final isStart   = _isStartDate(date, state.selectedRange);
    final isEnd     = _isEndDate(date, state.selectedRange);
    final isInRange = _isDateInRange(date, state.selectedRange);
    final isToday   = _isToday(date);
    final isPast    = _isPastDate(date);
    final isDisabled = !_isDateEnabled(date, state.minDate, state.maxDate) || isPast;
    final isHover   = _isHoverInRange(date, state);

    // ── text color ──────────────────────────────────────────────────────
    Color textColor;
    if (isDisabled) {
      textColor = Colors.black;
    } else if (isStart || isEnd) {
      textColor = Colors.black;
    } else if (isToday) {
      textColor = Colors.white;        
    } else if (isInRange || isHover) {
      textColor = Colors.black;       
    } else {
      textColor = const Color(0xFFCAC4D0);
    }

    BoxDecoration? innerDec;
    if (!isDisabled && (isStart || isEnd)) {
      innerDec = BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFECEFFF),
        border: Border.all(color: const Color(0xFF5B7CFF), width: 1.5),
      );
    } else if (!isDisabled && isToday && !isInRange && !isHover) {
      innerDec = const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF5B7CFF),
      );
    }

    final bgDec = isDisabled
        ? null
        : _buildRangeBg(
            date, state, isInRange, isHover, isStart, isEnd,
            colIndex, rowCells);

    Widget content = Center(
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 150),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
        child: Text('${date.day}'),
      ),
    );

    if (innerDec != null) {
      content = Container(
        width: 46,
        height: 46,
        decoration: innerDec,
        child: content,
      );
    }

    return MouseRegion(
      onEnter: isDisabled
          ? null
          : (_) => context.read<CalendarBloc>().add(SetHoverDate(date)),
      onExit: isDisabled
          ? null
          : (_) => context.read<CalendarBloc>().add(const SetHoverDate(null)),
      child: GestureDetector(
        onTap: isDisabled
            ? null
            : () => context.read<CalendarBloc>().add(SelectDate(date)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: bgDec,
          child: content,
        ),
      ),
    );
  }

  BoxDecoration? _buildRangeBg(
    DateTime date,
    CalendarState state,
    bool isInRange,
    bool isHover,
    bool isStart,
    bool isEnd,
    int colIndex,
    List<DateTime?> rowCells,
  ) {
    if (!isInRange && !isHover && !isStart && !isEnd) return null;

    const bg = Color(0xFFE8EEFF);
    const r  = Radius.circular(20);

    final prevDate   = colIndex > 0 ? rowCells[colIndex - 1] : null;
    final nextDate   = colIndex < 6 ? rowCells[colIndex + 1] : null;
    final prevActive = prevDate != null && _cellIsActive(prevDate, state);
    final nextActive = nextDate != null && _cellIsActive(nextDate, state);

    return BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.only(
        topLeft:     prevActive ? Radius.zero : r,
        bottomLeft:  prevActive ? Radius.zero : r,
        topRight:    nextActive ? Radius.zero : r,
        bottomRight: nextActive ? Radius.zero : r,
      ),
    );
  }

  bool _cellIsActive(DateTime date, CalendarState state) {
    if (!_isDateEnabled(date, state.minDate, state.maxDate)) return false;
    if (_isPastDate(date)) return false;
    return _isStartDate(date, state.selectedRange) ||
        _isEndDate(date, state.selectedRange) ||
        _isDateInRange(date, state.selectedRange) ||
        _isHoverInRange(date, state);
  }

  bool _isDateInRange(DateTime date, DateRange range) {
    if (!range.isComplete) return false;
    final n = range.normalize();
    return n.contains(date) &&
        !_isSameDay(date, n.startDate!) &&
        !_isSameDay(date, n.endDate!);
  }

  bool _isHoverInRange(DateTime date, CalendarState state) {
    if (state.hoverDate == null) return false;
    if (state.selectedRange.startDate == null) return false;
    if (state.selectedRange.endDate != null) return false;
    if (!_isDateEnabled(date, state.minDate, state.maxDate)) return false;
    if (_isPastDate(date)) return false;

    final temp = DateRange(
      startDate: state.selectedRange.startDate,
      endDate: state.hoverDate,
    ).normalize();

    return temp.contains(date) &&
        !_isSameDay(date, state.selectedRange.startDate!) &&
        !_isSameDay(date, state.hoverDate!);
  }

  bool _isToday(DateTime date) => _isSameDay(date, DateTime.now());

  bool _isPastDate(DateTime date) {
    final today = DateTime.now();
    return DateTime(date.year, date.month, date.day)
        .isBefore(DateTime(today.year, today.month, today.day));
  }

  bool _isDateEnabled(DateTime date, DateTime minDate, DateTime maxDate) {
    final d  = DateTime(date.year, date.month, date.day);
    final mn = DateTime(minDate.year, minDate.month, minDate.day);
    final mx = DateTime(maxDate.year, maxDate.month, maxDate.day);
    return (d.isAtSameMomentAs(mn) || d.isAfter(mn)) &&
        (d.isAtSameMomentAs(mx) || d.isBefore(mx));
  }

  bool _isStartDate(DateTime date, DateRange range) {
    if (range.startDate == null) return false;
    return _isSameDay(date, range.normalize().startDate!);
  }

  bool _isEndDate(DateTime date, DateRange range) {
    if (!range.isComplete) return false;
    return _isSameDay(date, range.normalize().endDate!);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int _getDaysInMonth(DateTime month) =>
      DateTime(month.year, month.month + 1, 0).day;
}