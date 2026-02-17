import 'package:calendar_app/data/calendar_mode.dart';
import 'package:calendar_app/data/data_range.dart';
import 'package:calendar_app/feautures/data/bloc/bloc/calendar_bloc.dart';
import 'package:calendar_app/feautures/data/bloc/event/calendar_event.dart';
import 'package:calendar_app/feautures/presentation/calendar_widgets/calendar_picker.dart';
import 'package:calendar_app/feautures/presentation/calendar_widgets/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarMode _mode = CalendarMode.range;
  DateRange? _selectedRange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
    
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCalendar(),
            ],
          ),
        ),
      ),
    );
  }

 
  Widget _buildCalendar() {
    return BlocProvider(
      create: (context) => CalendarBloc(
        validateDateFormat: di.sl(),
        parseDate: di.sl(),
        getCurrentDate: di.sl(),
        repository: di.sl(),
        onDateChanged: (range) {
          setState(() {
            _selectedRange = range;
          });
        },
      )..add(InitializeCalendar(
          mode: _mode,
          minDate: DateTime(2020, 1, 1),
          maxDate: DateTime(2030, 12, 31),
          initialRange: _selectedRange,
        )),
      child: CalendarPicker(
        mode: _mode,
        minDate: DateTime(2020, 1, 1),
        maxDate: DateTime(2030, 12, 31),
        initialRange: _selectedRange,
        onDateChanged: (range) {
          setState(() {
            _selectedRange = range;
          });
        },
      ),
    );
  }

}