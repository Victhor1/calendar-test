import 'package:flutter/material.dart';
import 'package:test_calendar/widgets/calendar_day_widget.dart';

class CustomCalendar extends StatefulWidget {
  static const int defaultScrollLimit = 5000;
  static const double _weekHeight = 40.0;
  static const double _monthHeight = _weekHeight * 6;

  static const List<String> _dayNames = ['D', 'L', 'M', 'M', 'J', 'V', 'S'];
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
  final Map<DateTime, ({int count, Color color})>? events;
  final int scrollBackLimit;
  final int scrollForwardLimit;
  final ValueChanged<DateTime>? onPageChanged;
  final ValueChanged<DateTime>? onDaySelected;

  const CustomCalendar.week({
    super.key,
    this.events,
    this.scrollBackLimit = defaultScrollLimit,
    this.scrollForwardLimit = defaultScrollLimit,
    this.onPageChanged,
    this.onDaySelected,
  }) : showFullCalendar = false;

  const CustomCalendar.month({
    super.key,
    this.events,
    this.scrollBackLimit = defaultScrollLimit,
    this.scrollForwardLimit = defaultScrollLimit,
    this.onPageChanged,
    this.onDaySelected,
  }) : showFullCalendar = true;

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  late PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.scrollBackLimit;
    _pageController = PageController(initialPage: _currentPage);
    if (widget.onPageChanged != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _notifyDateChanged(_currentPage);
      });
    }
  }

  @override
  void didUpdateWidget(CustomCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showFullCalendar != oldWidget.showFullCalendar ||
        widget.scrollBackLimit != oldWidget.scrollBackLimit) {
      _currentPage = widget.scrollBackLimit;
      _pageController.dispose();
      _pageController = PageController(initialPage: _currentPage);
      if (widget.onPageChanged != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _notifyDateChanged(_currentPage);
        });
      }
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  DateTime _getSunday(DateTime date) {
    int offset = date.weekday == 7 ? 0 : date.weekday;
    return date.subtract(Duration(days: offset));
  }

  void _notifyDateChanged(int pageIndex) {
    if (widget.onPageChanged == null) return;
    
    final DateTime now = DateTime.now();
    final int currentOffset = pageIndex - widget.scrollBackLimit;
    
    DateTime currentTargetDate;
    if (widget.showFullCalendar) {
      currentTargetDate = DateTime(now.year, now.month + currentOffset, 1);
    } else {
      currentTargetDate = _getSunday(now).add(Duration(days: currentOffset * 7));
    }
    
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
    final int currentOffset = _currentPage - widget.scrollBackLimit;

    DateTime currentTargetDate;
    if (widget.showFullCalendar) {
      currentTargetDate = DateTime(now.year, now.month + currentOffset, 1);
    } else {
      currentTargetDate = _getSunday(now).add(Duration(days: currentOffset * 7));
    }

    final String currentMonthName = CustomCalendar._monthNames[currentTargetDate.month - 1];
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
            return Expanded(
              child: Center(
                child: Text(
                  CustomCalendar._dayNames[index],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: widget.showFullCalendar
              ? CustomCalendar._monthHeight
              : CustomCalendar._weekHeight,
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
                final DateTime sunday = _getSunday(now);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (index) {
                    final DateTime currentDay = sunday.add(
                      Duration(days: index + (pageOffset * 7)),
                    );
                    
                    return CalendarDayWidget(
                      currentDay: currentDay,
                      isToday: _isSameDay(currentDay, now),
                      isCurrentMonth: true,
                      events: widget.events,
                      onTap: widget.onDaySelected != null
                          ? () => widget.onDaySelected!(currentDay)
                          : null,
                    );
                  }),
                );
              } else {
                final DateTime targetMonth = DateTime(
                  now.year,
                  now.month + pageOffset,
                  1,
                );
                final DateTime startGridDate = _getSunday(targetMonth);

                return SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    children: List.generate(6, (weekIndex) {
                      return SizedBox(
                        height: CustomCalendar._weekHeight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(7, (dayIndex) {
                            final DateTime currentDay = startGridDate.add(
                              Duration(days: weekIndex * 7 + dayIndex),
                            );
                            bool isCurrentMonth =
                                currentDay.month == targetMonth.month;

                            return CalendarDayWidget(
                              currentDay: currentDay,
                              isToday: _isSameDay(currentDay, now),
                              isCurrentMonth: isCurrentMonth,
                              events: widget.events,
                              onTap: widget.onDaySelected != null
                                  ? () => widget.onDaySelected!(currentDay)
                                  : null,
                            );
                          }),
                        ),
                      );
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
