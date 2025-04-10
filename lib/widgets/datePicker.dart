import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
enum _SelectorType { day, month, year }
class CustomCupertinoDatePicker extends StatefulWidget {
  final double itemExtent;
  final Widget selectionOverlay;
  final double diameterRatio;
  final Color? backgroundColor;
  final double offAxisFraction;
  final bool useMaginifier;
  final double magnification;
  final double squeeze;
  final void Function(DateTime) onSelectedItemChanged;
  // Text style of selected item
  final TextStyle? selectedStyle;
  // Text style of unselected item
  final TextStyle? unselectedStyle;
  // Text style of disabled item
  final TextStyle? disabledStyle;
  // Minimum selectable date
  final DateTime? minDate;
  // Maximum selectable date
  final DateTime? maxDate;
  // Initially selected date
  final DateTime? selectedDate;

  const CustomCupertinoDatePicker({
    Key? key,
    required this.itemExtent,
    required this.onSelectedItemChanged,
    this.minDate,
    this.maxDate,
    this.selectedDate,
    this.selectedStyle,
    this.unselectedStyle,
    this.disabledStyle,
    this.backgroundColor,
    this.squeeze = 1.45,
    this.diameterRatio = 1.1,
    this.magnification = 1.0,
    this.offAxisFraction = 0.0,
    this.useMaginifier = false,
    this.selectionOverlay = const CupertinoPickerDefaultSelectionOverlay(),
  }) : super(key: key);

  @override
  State<CustomCupertinoDatePicker> createState() =>
      _CustomCupertinoDatePickerState();
}

class _CustomCupertinoDatePickerState extends State<CustomCupertinoDatePicker> {
  late DateTime _minDate;
  late DateTime _maxDate;
  late DateTime _selectedDate;
  late int _selectedDayIndex;
  late int _selectedMonthIndex;
  late int _selectedYearIndex;
  late final FixedExtentScrollController _dayScrollController;
  late final FixedExtentScrollController _monthScrollController;
  late final FixedExtentScrollController _yearScrollController;
  final _days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  final _months = [
    'Janvier',
    'Février',
    'Mars',
    'Avril',
    'Mai',
    'Juin',
    'Juillet',
    'Aaût',
    'Septembre',
    'Octobre',
    'Novembre',
    'Décembre',
  ];

  @override
  void initState() {
    super.initState();
    _validateDates();
    _dayScrollController = FixedExtentScrollController();
    _monthScrollController = FixedExtentScrollController();
    _yearScrollController = FixedExtentScrollController();
    _initDates();
  }

  void _validateDates() {
    if (widget.minDate != null && widget.maxDate != null) {
      assert(!widget.minDate!.isAfter(widget.maxDate!));
    }
    if (widget.minDate != null && widget.selectedDate != null) {
      assert(!widget.minDate!.isAfter(widget.selectedDate!));
    }
    if (widget.maxDate != null && widget.selectedDate != null) {
      assert(!widget.selectedDate!.isAfter(widget.maxDate!));
    }
  }

  void _initDates() {
    final currentDate = DateTime.now();
    _minDate = widget.minDate ?? DateTime(currentDate.year - 100);
    _maxDate = widget.maxDate ?? DateTime(currentDate.year + 100);
    if (widget.selectedDate != null) {
      _selectedDate = widget.selectedDate!;
    } else if (!currentDate.isBefore(_minDate) && !currentDate.isAfter(_maxDate)) {
      _selectedDate = currentDate;
    } else {
      _selectedDate = _minDate;
    }
    _selectedDayIndex = _selectedDate.day - 1;
    _selectedMonthIndex = _selectedDate.month - 1;
    _selectedYearIndex = _selectedDate.year - _minDate.year;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollList(_dayScrollController, _selectedDayIndex);
      _scrollList(_monthScrollController, _selectedMonthIndex);
      _scrollList(_yearScrollController, _selectedYearIndex);
    });
  }

  void _scrollList(FixedExtentScrollController controller, int index) {
    controller.animateToItem(
      index,
      curve: Curves.easeIn,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _dayScrollController.dispose();
    _monthScrollController.dispose();
    _yearScrollController.dispose();
    super.dispose();
  }

  bool _isLeapYear() {
    final year = _minDate.year + _selectedYearIndex;
    return year % 4 == 0 && (year % 100 != 0 || (year % 100 == 0 && year % 400 == 0));
  }

  int _numberOfDays() {
    if (_selectedMonthIndex == 1) {
      _days[1] = _isLeapYear() ? 29 : 28;
    }
    return _days[_selectedMonthIndex];
  }


void _onSelectedItemChanged(int index, _SelectorType type) {
  DateTime temp;
  switch (type) {
    case _SelectorType.day:
      temp = DateTime(
        _minDate.year + _selectedYearIndex,
        _selectedMonthIndex + 1,
        index + 1,
      );
      break;
    case _SelectorType.month:
      temp = DateTime(
        _minDate.year + _selectedYearIndex,
        index + 1,
        _selectedDayIndex + 1,
      );
      break;
    case _SelectorType.year:
      temp = DateTime(
        _minDate.year + index,
        _selectedMonthIndex + 1,
        _selectedDayIndex + 1,
      );
      break;
  }

  if (temp.isBefore(_minDate) || temp.isAfter(_maxDate)) {
    switch (type) {
      case _SelectorType.day:
        _dayScrollController.jumpToItem(_selectedDayIndex);
        break;
      case _SelectorType.month:
        _monthScrollController.jumpToItem(_selectedMonthIndex);
        break;
      case _SelectorType.year:
        _yearScrollController.jumpToItem(_selectedYearIndex);
        break;
    }
    return;
  }

  _selectedDate = temp;

  switch (type) {
    case _SelectorType.day:
      _selectedDayIndex = index;
      break;
    case _SelectorType.month:
      _selectedMonthIndex = index;

      if (_selectedMonthIndex == 1 && _selectedDayIndex > 27) {
        _selectedDayIndex = _isLeapYear() ? 28 : 27;
      }

      if (_selectedDayIndex == 30 && _days[_selectedMonthIndex] == 30) {
        _selectedDayIndex = 29;
      }
      break;
    case _SelectorType.year:
      _selectedYearIndex = index;
      if (!_isLeapYear() &&
          _selectedMonthIndex == 1 &&
          _selectedDayIndex == 28) {
        _selectedDayIndex = 27;
      }
      break;
  }

  setState(() {});
  widget.onSelectedItemChanged(_selectedDate);
}

bool _isDisabled(int index, _SelectorType type) {
  DateTime temp;
  switch (type) {
    case _SelectorType.day:
      temp = DateTime(
        _minDate.year + _selectedYearIndex,
        _selectedMonthIndex + 1,
        index + 1,
      );
      break;
    case _SelectorType.month:
      temp = DateTime(
        _minDate.year + _selectedYearIndex,
        index + 1,
        _selectedDayIndex + 1,
      );
      break;
    case _SelectorType.year:
      temp = DateTime(
        _minDate.year + index,
        _selectedMonthIndex + 1,
        _selectedDayIndex + 1,
      );
      break;
  }
  return temp.isAfter(_maxDate) || temp.isBefore(_minDate);
}

Widget _selector({
  required List<dynamic> values,
  required int selectedValueIndex,
  required bool Function(int) isDisabled,
  required void Function(int) onSelectedItemChanged,
  required FixedExtentScrollController scrollController,
}) {
  return CupertinoPicker.builder(
    childCount: values.length,
    squeeze: widget.squeeze,
    itemExtent: widget.itemExtent,
    scrollController: scrollController,
    useMagnifier: widget.useMaginifier,
    diameterRatio: widget.diameterRatio,
    magnification: widget.magnification,
    backgroundColor: widget.backgroundColor,
    offAxisFraction: widget.offAxisFraction,
    selectionOverlay: widget.selectionOverlay,
    onSelectedItemChanged: (int index) {
      if (!isDisabled(index)) {
        onSelectedItemChanged(index);
      }
    },
    itemBuilder: (context, index) => Container(
      height: widget.itemExtent,
      alignment: Alignment.center,
      child: Text(
        '${values[index]}',
        style: index == selectedValueIndex
            ? widget.selectedStyle
            : isDisabled(index)
            ? widget.disabledStyle
            : widget.unselectedStyle,
      ),
    ),
  );
}

Widget _daySelector() {
  return _selector(
    values: List.generate(_numberOfDays(), (index) => index + 1),
    selectedValueIndex: _selectedDayIndex,
    scrollController: _dayScrollController,
    isDisabled: (index) => _isDisabled(index, _SelectorType.day),
    onSelectedItemChanged: (v) =>
        _onSelectedItemChanged(v, _SelectorType.day),
  );
}

Widget _monthSelector() {
  return _selector(
    values: _months,
    selectedValueIndex: _selectedMonthIndex,
    scrollController: _monthScrollController,
    isDisabled: (index) => _isDisabled(index, _SelectorType.month),
    onSelectedItemChanged: (v) =>
        _onSelectedItemChanged(v, _SelectorType.month),
  );
}

Widget _yearSelector() {
  return _selector(
    values: List.generate(
      _maxDate.year - _minDate.year + 1,
          (index) => _minDate.year + index,
    ),
    selectedValueIndex: _selectedYearIndex,
    scrollController: _yearScrollController,
    isDisabled: (index) => _isDisabled(index, _SelectorType.year),
    onSelectedItemChanged: (v) =>
        _onSelectedItemChanged(v, _SelectorType.year),
  );
}

@override
Widget build(BuildContext context) {
  return Row(
    children: [
      Expanded(child: _monthSelector()),
      Expanded(child: _daySelector()),
      Expanded(child: _yearSelector()),
    ],
  );
}
}

class CustomCupertinoPickerApp extends StatefulWidget {
  const CustomCupertinoPickerApp({Key? key}) : super(key: key);
  @override
  State<CustomCupertinoPickerApp> createState() =>
      _CustomCupertinoPickerAppState();
}

class _CustomCupertinoPickerAppState extends State<CustomCupertinoPickerApp> {
  late final DateTime _minDate;
  late final DateTime _maxDate;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final currentDate = DateTime.now();
    _minDate = DateTime(
      currentDate.year - 100,
      currentDate.month,
      currentDate.day,
    );
    _maxDate = DateTime(
      currentDate.year - 18,
      currentDate.month,
      currentDate.day,
    );
    _selectedDate = _maxDate;
  }

  @override
  Widget build(BuildContext context) {
    return

         Center(
          child: SizedBox(
            height: 300,
            child: CustomCupertinoDatePicker(
              itemExtent: 50,
              minDate: _minDate,
              maxDate: _maxDate,
              selectedDate: _selectedDate,
              selectionOverlay: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(107, 154, 239, 0.2),
                 // borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              selectedStyle:  TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 15.sp,
                fontFamily: 'Inter'
              ),
              unselectedStyle: TextStyle(
                color: Colors.grey[800],
                fontSize: 15.sp,
                  fontFamily: 'Inter'
              ),
              disabledStyle: TextStyle(
                color: Colors.grey[800],
                fontSize: 15.sp,
                  fontFamily: 'Inter'
              ),
              onSelectedItemChanged: (date) => setState(() {
                _selectedDate = date;
            //    print (_selectedDate);
              } ),

            ),
          ),
        );


  }
}
