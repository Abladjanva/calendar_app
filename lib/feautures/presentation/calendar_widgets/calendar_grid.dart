import 'package:calendar_app/data/data_range.dart';
import 'package:calendar_app/feautures/data/bloc/bloc/calendar_bloc.dart';
import 'package:calendar_app/feautures/data/bloc/event/calendar_event.dart';
import 'package:calendar_app/feautures/data/bloc/state/calendar_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CalendarGrid extends StatelessWidget {
  final List<DateTime>? excludedDates;

  const CalendarGrid({Key? key, this.excludedDates}) : super(key: key);

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
      cells.add(
        DateTime(state.displayedMonth.year, state.displayedMonth.month, d),
      );
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
            child: _buildDayCell(context, date, state, colIndex),
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
  ) {
    final isStart = _isStartDate(date, state.selectedRange);
    final isEnd = _isEndDate(date, state.selectedRange);
    final isInRange = _isDateInRange(date, state.selectedRange);
    final isToday = _isToday(date);
    final isActive =
        _isDateEnabled(date, state.minDate, state.maxDate) &&
        !_isFutureDate(date) &&
        !_isExcludedDate(date);

    final isRangeMode = state.mode.toString().contains('range');
    final isHoveringRange = isRangeMode ? _isHoverInRange(date, state) : false;
    final isHoverTarget =
        state.hoverDate != null && _isSameDay(date, state.hoverDate!);

    const Color rangeFillColor = Color(0xFFECEFFF);
    const Color primaryBlue = Color(0xFF5B7CFF);
    const Color disabledGrey = Color(0xFFCAC4D0);

    Color textColor = Colors.black;
    if (!isActive) textColor = disabledGrey;
    if (isToday && !isInRange && !isStart && !isEnd) textColor = Colors.white;

    final bool showTrack = isInRange || isHoveringRange || isStart || isEnd;
    final bool hasSelection =
        state.selectedRange.startDate != null &&
        (state.selectedRange.endDate != null || state.hoverDate != null);

    return MouseRegion(
      onEnter: isActive
          ? (_) => context.read<CalendarBloc>().add(SetHoverDate(date))
          : null,
      onExit: isActive
          ? (_) => context.read<CalendarBloc>().add(const SetHoverDate(null))
          : null,
      child: GestureDetector(
        onTap: isActive
            ? () => context.read<CalendarBloc>().add(SelectDate(date))
            : null,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (showTrack && hasSelection)
              _buildRangeTrack(
                isStart,
                isEnd,
                isInRange || isHoveringRange,
                colIndex,
                rangeFillColor,
              ),

            Container(
              width: 46,
              height: 46,
              decoration: _getCircleDecoration(
                isStart,
                isEnd,
                isToday,
                isInRange,
                isHoverTarget,
                rangeFillColor,
                primaryBlue,
              ),
              child: Center(
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeTrack(
    bool isStart,
    bool isEnd,
    bool isMiddle,
    int colIndex,
    Color color,
  ) {
    const Radius r = Radius.circular(20);
    const double trackHeight = 48.0;

    final bool isFirstInRow = colIndex == 0;
    final bool isLastInRow = colIndex == 6;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Expanded(
              child: Container(
                height: trackHeight,
                decoration: BoxDecoration(
                  color: (isMiddle || isEnd) && !isStart
                      ? color
                      : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topLeft: isFirstInRow ? r : Radius.zero,
                    bottomLeft: isFirstInRow ? r : Radius.zero,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: trackHeight,
                decoration: BoxDecoration(
                  color: (isMiddle || isStart) && !isEnd
                      ? color
                      : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topRight: isLastInRow ? r : Radius.zero,
                    bottomRight: isLastInRow ? r : Radius.zero,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  BoxDecoration? _getCircleDecoration(
    bool isStart,
    bool isEnd,
    bool isToday,
    bool isInRange,
    bool isHoverTarget,
    Color bg,
    Color blue,
  ) {
    if (isStart || isEnd || isHoverTarget) {
      return BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        border: Border.all(color: blue, width: 1.5),
      );
    }
    if (isToday && !isInRange) {
      return const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF5B7CFF),
      );
    }
    return null;
  }

  bool _isExcludedDate(DateTime date) =>
      excludedDates?.any((d) => _isSameDay(date, d)) ?? false;
  bool _isToday(DateTime date) => _isSameDay(date, DateTime.now());
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
  int _getDaysInMonth(DateTime month) =>
      DateTime(month.year, month.month + 1, 0).day;
  bool _isFutureDate(DateTime date) {
    final now = DateTime.now();
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).isAfter(DateTime(now.year, now.month, now.day));
  }

  bool _isDateEnabled(DateTime date, DateTime min, DateTime max) {
    final d = DateTime(date.year, date.month, date.day);
    return !d.isBefore(DateTime(min.year, min.month, min.day)) &&
        !d.isAfter(DateTime(max.year, max.month, max.day));
  }

  bool _isStartDate(DateTime date, DateRange range) =>
      range.startDate != null && _isSameDay(date, range.normalize().startDate!);
  bool _isEndDate(DateTime date, DateRange range) =>
      range.isComplete && _isSameDay(date, range.normalize().endDate!);
  bool _isDateInRange(DateTime date, DateRange range) {
    if (!range.isComplete) return false;
    final n = range.normalize();
    return n.contains(date) &&
        !_isSameDay(date, n.startDate!) &&
        !_isSameDay(date, n.endDate!);
  }

  bool _isHoverInRange(DateTime date, CalendarState state) {
    if (state.hoverDate == null ||
        state.selectedRange.startDate == null ||
        state.selectedRange.endDate != null)
      return false;
    final temp = DateRange(
      startDate: state.selectedRange.startDate,
      endDate: state.hoverDate,
    ).normalize();
    return temp.contains(date) &&
        !_isSameDay(date, state.selectedRange.startDate!) &&
        !_isSameDay(date, state.hoverDate!);
  }
}
