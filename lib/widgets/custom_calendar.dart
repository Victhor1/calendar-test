import 'package:flutter/material.dart';
import 'package:test_calendar/widgets/calendar_day_widget.dart';

class CustomCalendar extends StatefulWidget {
  static const int defaultScrollLimit = 5000;
  static const double _weekHeight = 40.0;
  // static const double _monthHeight = (_weekHeight * 6) + 10.0;

  static const List<String> _dayNames = [
    'DOM',
    'LUN',
    'MAR',
    'MIE',
    'JUE',
    'VIE',
    'SAB',
  ];
  static const List<String> _monthNames = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  final bool showFullCalendar;
  final bool singleLetterDayNames;
  final DateTime? selectedDate;
  final Map<DateTime, ({int count, Color color})>? events;
  final bool disableDaysWithoutEvents;
  final int scrollBackLimit;
  final int scrollForwardLimit;
  final ValueChanged<DateTime>? onPageChanged;
  final ValueChanged<DateTime>? onDaySelected;
  final ValueNotifier<double>? dragProgress;

  const CustomCalendar.week({
    super.key,
    this.events,
    this.disableDaysWithoutEvents = false,
    this.scrollBackLimit = defaultScrollLimit,
    this.scrollForwardLimit = defaultScrollLimit,
    this.singleLetterDayNames = false,
    this.selectedDate,
    this.onPageChanged,
    this.onDaySelected,
    this.dragProgress,
  }) : showFullCalendar = false;

  const CustomCalendar.month({
    super.key,
    this.events,
    this.disableDaysWithoutEvents = false,
    this.scrollBackLimit = defaultScrollLimit,
    this.scrollForwardLimit = defaultScrollLimit,
    this.singleLetterDayNames = false,
    this.selectedDate,
    this.onPageChanged,
    this.onDaySelected,
    this.dragProgress,
  }) : showFullCalendar = true;

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  late PageController _pageController;
  late int _currentPage;
  late DateTime _selectedDate;
  late DateTime _initialSelectedDate;
  late DateTime _baseDate;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.scrollBackLimit;
    _pageController = PageController(initialPage: _currentPage);
    _selectedDate = widget.selectedDate ?? DateTime.now();
    _initialSelectedDate = widget.selectedDate ?? DateTime.now();
    _baseDate = widget.selectedDate ?? DateTime.now();
    if (widget.onPageChanged != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _notifyDateChanged(_currentPage);
      });
    }
  }

  bool _isDateInCurrentPage(DateTime date, int pageIndex) {
    int pageOffset = pageIndex - widget.scrollBackLimit;
    if (widget.showFullCalendar) {
      final DateTime targetMonth = DateTime(
        _baseDate.year,
        _baseDate.month + pageOffset,
        1,
      );
      return date.year == targetMonth.year && date.month == targetMonth.month;
    } else {
      final DateTime sunday = _getSunday(_baseDate);
      final DateTime weekStart = DateTime(
        sunday.year,
        sunday.month,
        sunday.day + (pageOffset * 7),
      );
      final DateTime weekEnd = DateTime(
        weekStart.year,
        weekStart.month,
        weekStart.day + 6,
      );
      final DateTime dateOnly = DateTime(date.year, date.month, date.day);
      return !dateOnly.isBefore(weekStart) && !dateOnly.isAfter(weekEnd);
    }
  }

  @override
  void didUpdateWidget(CustomCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != null &&
        widget.selectedDate != oldWidget.selectedDate) {
      _selectedDate = widget.selectedDate!;
      _initialSelectedDate = widget.selectedDate!;
      if (!_isDateInCurrentPage(widget.selectedDate!, _currentPage)) {
        _baseDate = widget.selectedDate!;
        _currentPage = widget.scrollBackLimit;
        if (_pageController.hasClients) {
          _pageController.jumpToPage(_currentPage);
        }
        if (widget.onPageChanged != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _notifyDateChanged(_currentPage);
          });
        }
      }
    }
    if (widget.showFullCalendar != oldWidget.showFullCalendar ||
        widget.scrollBackLimit != oldWidget.scrollBackLimit ||
        widget.scrollForwardLimit != oldWidget.scrollForwardLimit) {
      _baseDate = _selectedDate;
      _currentPage = widget.scrollBackLimit;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_currentPage);
      }
      if (widget.onPageChanged != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _notifyDateChanged(_currentPage);
        });
      }
    }
  }

  void _onDaySelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    widget.onDaySelected?.call(date);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  DateTime _getSunday(DateTime date) {
    int offset = date.weekday == 7 ? 0 : date.weekday;
    return DateTime(date.year, date.month, date.day - offset);
  }

  DateTime _getTargetDate(int pageIndex) {
    final int currentOffset = pageIndex - widget.scrollBackLimit;
    if (widget.showFullCalendar) {
      return DateTime(_baseDate.year, _baseDate.month + currentOffset, 1);
    } else {
      final DateTime sunday = _getSunday(_baseDate);
      return DateTime(
        sunday.year,
        sunday.month,
        sunday.day + (currentOffset * 7),
      );
    }
  }

  void _notifyDateChanged(int pageIndex) {
    if (widget.onPageChanged == null) return;
    final DateTime currentTargetDate = _getTargetDate(pageIndex);
    widget.onPageChanged!(currentTargetDate);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime currentTargetDate = _getTargetDate(_currentPage);

    final String currentMonthName =
        CustomCalendar._monthNames[currentTargetDate.month - 1];
    final String currentYear = currentTargetDate.year.toString();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showFullCalendar)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 10.0, top: 5.0),
            child: Text(
              '$currentMonthName $currentYear',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (index) {
            final String dayName = CustomCalendar._dayNames[index];
            return Expanded(
              child: Center(
                child: Text(
                  widget.singleLetterDayNames ? dayName[0] : dayName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        ValueListenableBuilder<double>(
          valueListenable: widget.dragProgress ?? ValueNotifier(0.0),
          builder: (context, progress, child) {
            double gap = 10.0 * (1.0 - progress);
            return AnimatedContainer(
              duration: widget.dragProgress != null
                  ? Duration.zero
                  : const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: widget.showFullCalendar
                  ? (CustomCalendar._weekHeight * 6) + gap
                  : CustomCalendar._weekHeight,
              child: child,
            );
          },
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.scrollBackLimit + 1 + widget.scrollForwardLimit,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              _notifyDateChanged(index);
            },
            itemBuilder: (context, pageIndex) {
              int pageOffset = pageIndex - widget.scrollBackLimit;

              if (!widget.showFullCalendar) {
                final DateTime sunday = _getSunday(_baseDate);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (index) {
                    final DateTime currentDay = DateTime(
                      sunday.year,
                      sunday.month,
                      sunday.day + index + (pageOffset * 7),
                    );

                    return CalendarDayWidget(
                      currentDay: currentDay,
                      isSelected: _isSameDay(currentDay, _selectedDate),
                      isInitialSelected: _isSameDay(
                        currentDay,
                        _initialSelectedDate,
                      ),
                      isToday: _isSameDay(currentDay, now),
                      isCurrentMonth: true,
                      events: widget.events,
                      disableDaysWithoutEvents: widget.disableDaysWithoutEvents,
                      onTap: () => _onDaySelected(currentDay),
                    );
                  }),
                );
              } else {
                final DateTime targetMonth = DateTime(
                  _baseDate.year,
                  _baseDate.month + pageOffset,
                  1,
                );
                final DateTime startGridDate = _getSunday(targetMonth);

                return SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    children: List.generate(6, (weekIndex) {
                      Widget weekRow = SizedBox(
                        height: CustomCalendar._weekHeight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(7, (dayIndex) {
                            final DateTime currentDay = DateTime(
                              startGridDate.year,
                              startGridDate.month,
                              startGridDate.day + (weekIndex * 7 + dayIndex),
                            );
                            bool isCurrentMonth =
                                currentDay.month == targetMonth.month;

                            return CalendarDayWidget(
                              currentDay: currentDay,
                              isSelected:
                                  isCurrentMonth &&
                                  _isSameDay(currentDay, _selectedDate),
                              isInitialSelected:
                                  isCurrentMonth &&
                                  _isSameDay(currentDay, _initialSelectedDate),
                              isToday:
                                  isCurrentMonth && _isSameDay(currentDay, now),
                              isCurrentMonth: isCurrentMonth,
                              events: isCurrentMonth ? widget.events : null,
                              disableDaysWithoutEvents:
                                  widget.disableDaysWithoutEvents,
                              onTap: isCurrentMonth
                                  ? () => _onDaySelected(currentDay)
                                  : null,
                            );
                          }),
                        ),
                      );

                      if (weekIndex == 0) {
                        return ValueListenableBuilder<double>(
                          valueListenable:
                              widget.dragProgress ?? ValueNotifier(0.0),
                          builder: (context, progress, child) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: 10.0 * (1.0 - progress),
                              ),
                              child: weekRow,
                            );
                          },
                        );
                      }

                      return weekRow;
                    }),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
