import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class DateInputField extends StatefulWidget {
  final String? initialValue;
  final String? hint;
  final Function(String) onDateChanged;
  final bool enabled;
  final bool isToday;
  final DateTime? minDate;
  final DateTime? maxDate;
  final List<DateTime>? excludedDates;
  final bool isEndField; 
  final DateTime? startDate; 
  final TextAlign textAlign;

  const DateInputField({
    Key? key,
    this.initialValue,
    this.hint,
    required this.onDateChanged,
    this.enabled = true,  
    this.isToday = false,
    this.minDate,
    this.maxDate,
    this.excludedDates,
    this.isEndField = false,
    this.startDate,
    this.textAlign = TextAlign.center,

  }) : super(key: key);

  @override
  State<DateInputField> createState() => _DateInputFieldState();
}

class _DateInputFieldState extends State<DateInputField> {
  late TextEditingController _controller;
  late MaskTextInputFormatter _maskFormatter;
  late FocusNode _focusNode;
  String? _lastValidValue;

  String get _todayFormatted {
    final now = DateTime.now();
    final d = now.day.toString().padLeft(2, '0');
    final m = now.month.toString().padLeft(2, '0');
    return '$d.$m.${now.year}';
  }

  @override
  void initState() {
    super.initState();
    _maskFormatter = MaskTextInputFormatter(
      mask: '##.##.####',
      filter: {'#': RegExp(r'[0-9]')},
    );
    _focusNode = FocusNode();
    
    final initial = widget.initialValue ?? '';
    _controller = TextEditingController(text: initial);
    _lastValidValue = initial.isNotEmpty ? initial : null;

    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(DateInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      final val = widget.initialValue ?? '';
      _controller.text = val;
      _lastValidValue = val.isNotEmpty ? val : null;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  bool _isValid(String value) {
    if (value.length != 10) return false;
    final parts = value.split('.');
    if (parts.length != 3) return false;
    final day   = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year  = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return false;
    if (month < 1 || month > 12) return false;
    if (day < 1 || day > 31) return false;
    if (year < 1000) return false;
    
    try {
      final dt = DateTime(year, month, day);
      if (dt.day != day || dt.month != month || dt.year != year) return false;
      
      if (widget.minDate != null) {
        final minOnly = DateTime(widget.minDate!.year, widget.minDate!.month, widget.minDate!.day);
        final dateOnly = DateTime(dt.year, dt.month, dt.day);
        if (dateOnly.isBefore(minOnly)) return false;
      }
      
      if (widget.maxDate != null) {
        final maxOnly = DateTime(widget.maxDate!.year, widget.maxDate!.month, widget.maxDate!.day);
        final dateOnly = DateTime(dt.year, dt.month, dt.day);
        if (dateOnly.isAfter(maxOnly)) return false;
      }
      
      if (widget.excludedDates != null) {
        for (final excluded in widget.excludedDates!) {
          if (dt.year == excluded.year && 
              dt.month == excluded.month && 
              dt.day == excluded.day) {
            return false;
          }
        }
      }
      
      final today = DateTime.now();
      final todayOnly = DateTime(today.year, today.month, today.day);
      final dateOnly = DateTime(dt.year, dt.month, dt.day);
      if (dateOnly.isAfter(todayOnly)) return false;
      
      if (widget.isEndField && widget.startDate != null) {
        final startOnly = DateTime(
          widget.startDate!.year, 
          widget.startDate!.month, 
          widget.startDate!.day
        );
        final dateOnly = DateTime(dt.year, dt.month, dt.day);
        if (dateOnly.isBefore(startOnly)) return false;
      }
      
      return true;
    } catch (_) {
      return false;
    }
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _submitValue();
    }
  }

  void _submitValue() {
    final value = _controller.text;
    if (value.isEmpty) {
      return;
    }
    
    if (value.length == 10 && _isValid(value)) {
      _lastValidValue = value;
      widget.onDateChanged(value);
    } else {
      final rollback = _lastValidValue ?? '';
      _controller.text = rollback;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: rollback.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.isToday
        ? const Color(0xFF556EE6)
        : const Color(0xFFE2E8F0);
    final textColor = widget.isToday
        ? Colors.black
        : const Color(0xFF79747E);

   return TextField(
  controller: _controller,
  focusNode: _focusNode,
  enabled: widget.enabled,
  inputFormatters: [_maskFormatter],
  keyboardType: TextInputType.number,
  textAlign: widget.textAlign,
  style: TextStyle(
    color: textColor,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
  ),
  decoration: InputDecoration(
    hintText: widget.hint ?? '',
    hintStyle: TextStyle(
      color: textColor.withOpacity(0.45),
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
    ),
    floatingLabelAlignment: FloatingLabelAlignment.center,

    
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borderColor, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF556EE6), width: 1.5),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borderColor, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),
  ),
  onSubmitted: (_) => _submitValue(),
);}}