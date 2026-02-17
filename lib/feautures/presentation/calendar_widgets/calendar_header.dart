import 'package:calendar_app/feautures/data/bloc/bloc/calendar_bloc.dart';
import 'package:calendar_app/feautures/data/bloc/event/calendar_event.dart';
import 'package:calendar_app/feautures/data/bloc/state/calendar_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class CalendarHeader extends StatelessWidget {
  const CalendarHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (context, state) {
        return Column(
          children: [
            _buildYearNavigation(context, state),
            const SizedBox(height: 16),
            _buildMonthNavigation(context, state),
          ],
        );
      },
    );
  }

  Widget _buildYearNavigation(BuildContext context, CalendarState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: SvgPicture.asset('assets/icons/arrow_back.svg'),
          onPressed: () {
            context.read<CalendarBloc>().add(const NavigateToPreviousYear());
          },
        ),
        Text(
          '${state.displayedMonth.year}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: SvgPicture.asset('assets/icons/arrow_next.svg'),
          onPressed: () {
            context.read<CalendarBloc>().add(const NavigateToNextYear());
          },
        ),
      ],
    );
  }

  Widget _buildMonthNavigation(BuildContext context, CalendarState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: SvgPicture.asset('assets/icons/arrow_back.svg'),
          onPressed: () {
            context.read<CalendarBloc>().add(const NavigateToPreviousMonth());
          },
        ),
        Expanded(
          child: _buildMonthDropdown(context, state),
        ),
        IconButton(
          icon: SvgPicture.asset('assets/icons/arrow_next.svg'),
          onPressed: () {
            context.read<CalendarBloc>().add(const NavigateToNextMonth());
          },
        ),
      ],
    );
  }

  Widget _buildMonthDropdown(BuildContext context, CalendarState state) {
    return PopupMenuButton<int>(
      offset: const Offset(0, 45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 8,
      color: Colors.white,
      constraints: const BoxConstraints(
        minWidth: 242,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _getMonthName(state.displayedMonth.month),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
      onSelected: (int month) {
        context.read<CalendarBloc>().add(SelectMonth(month));
      },
      itemBuilder: (BuildContext context) {
        return _buildMonthMenuItems(state);
      },
    );
  }

  List<PopupMenuEntry<int>> _buildMonthMenuItems(CalendarState state) {
    List<PopupMenuEntry<int>> items = [];

    final now = DateTime.now();
    final isCurrentYear = state.displayedMonth.year == now.year;

    for (int index = 0; index < 12; index++) {
      final month = index + 1;
      final isSelected = month == state.displayedMonth.month;
      // Current = the real current month in real current year
      final isCurrentMonth = isCurrentYear && month == now.month;

      items.add(
        PopupMenuItem<int>(
          value: month,
          padding: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            color: isSelected ? const Color(0xFFECEFFF) : Colors.transparent,
            child: Text(
              _getMonthName(month),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isCurrentMonth ? Colors.black : const Color(0xFF79747E),
              ),
            ),
          ),
        ),
      );

      if (index < 11) {
        items.add(const PopupMenuDivider(height: 0.1));
      }
    }

    return items;
  }

  String _getMonthName(int month) {
    const months = [
      'Январь',
      'Февраль',
      'Март',
      'Апрель',
      'Май',
      'Июнь',
      'Июль',
      'Август',
      'Сентябрь',
      'Октябрь',
      'Ноябрь',
      'Декабрь'
    ];
    return months[month - 1];
  }
}