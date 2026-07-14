import 'package:flutter/material.dart';

class CustomCalendar extends StatefulWidget {
  final bool showFullCalendar;
  final Map<DateTime, int>? eventsCount;
  final int scrollBackLimit;
  final int scrollForwardLimit;
  final ValueChanged<DateTime>? onPageChanged;
  final ValueChanged<DateTime>? onDaySelected;

  const CustomCalendar.week({
    super.key,
    this.eventsCount,
    this.scrollBackLimit = 5000,
    this.scrollForwardLimit = 5000,
    this.onPageChanged,
    this.onDaySelected,
  }) : showFullCalendar = false;

  const CustomCalendar.month({
    super.key,
    this.eventsCount,
    this.scrollBackLimit = 5000,
    this.scrollForwardLimit = 5000,
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

  void _notifyDateChanged(int pageIndex) {
    if (widget.onPageChanged == null) return;
    DateTime now = DateTime.now();
    int offset = now.weekday == 7 ? 0 : now.weekday;
    DateTime sunday = now.subtract(Duration(days: offset));
    int currentOffset = pageIndex - widget.scrollBackLimit;
    DateTime currentTargetDate = widget.showFullCalendar
        ? DateTime(now.year, now.month + currentOffset, 1)
        : sunday.add(Duration(days: currentOffset * 7));
    widget.onPageChanged!(currentTargetDate);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    int offset = now.weekday == 7 ? 0 : now.weekday;
    DateTime sunday = now.subtract(Duration(days: offset));
    List<String> dayNames = ['D', 'L', 'M', 'M', 'J', 'V', 'S'];
    List<String> monthNames = [
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

    int currentOffset = _currentPage - widget.scrollBackLimit;
    DateTime currentTargetDate = widget.showFullCalendar
        ? DateTime(now.year, now.month + currentOffset, 1)
        : sunday.add(Duration(days: currentOffset * 7));

    String currentMonthName = monthNames[currentTargetDate.month - 1];
    String currentYear = currentTargetDate.year.toString();

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
                  dayNames[index],
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
          height: widget.showFullCalendar ? 240 : 40,
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
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (index) {
                    DateTime currentDay = sunday.add(
                      Duration(days: index + (pageOffset * 7)),
                    );
                    bool isToday =
                        currentDay.year == now.year &&
                        currentDay.month == now.month &&
                        currentDay.day == now.day;
                    return CalendarDayWidget(
                      currentDay: currentDay,
                      isToday: isToday,
                      isCurrentMonth: true,
                      eventsCount: widget.eventsCount,
                      onTap: widget.onDaySelected != null
                          ? () => widget.onDaySelected!(currentDay)
                          : null,
                    );
                  }),
                );
              } else {
                DateTime targetMonth = DateTime(
                  now.year,
                  now.month + pageOffset,
                  1,
                );
                int firstDayWeekday = targetMonth.weekday;
                int daysToSubtract = firstDayWeekday == 7 ? 0 : firstDayWeekday;
                DateTime startGridDate = targetMonth.subtract(
                  Duration(days: daysToSubtract),
                );

                return SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    children: List.generate(6, (weekIndex) {
                      return SizedBox(
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(7, (dayIndex) {
                            DateTime currentDay = startGridDate.add(
                              Duration(days: weekIndex * 7 + dayIndex),
                            );
                            bool isToday =
                                currentDay.year == now.year &&
                                currentDay.month == now.month &&
                                currentDay.day == now.day;
                            bool isCurrentMonth =
                                currentDay.month == targetMonth.month;

                            return CalendarDayWidget(
                              currentDay: currentDay,
                              isToday: isToday,
                              isCurrentMonth: isCurrentMonth,
                              eventsCount: widget.eventsCount,
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

class CalendarDayWidget extends StatelessWidget {
  final DateTime currentDay;
  final bool isToday;
  final bool isCurrentMonth;
  final Map<DateTime, int>? eventsCount;
  final VoidCallback? onTap;

  const CalendarDayWidget({
    super.key,
    required this.currentDay,
    required this.isToday,
    required this.isCurrentMonth,
    this.eventsCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    int count = 0;
    if (eventsCount != null) {
      DateTime key = DateTime(
        currentDay.year,
        currentDay.month,
        currentDay.day,
      );
      count = eventsCount![key] ?? 0;
    }

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Container(
            width: 45,
            height: 45,
            decoration: isToday
                ? BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  )
                : null,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  currentDay.day.toString(),
                  style: TextStyle(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: isCurrentMonth
                        ? (isToday ? Colors.black : null)
                        : Colors.grey.withValues(alpha: .5),
                  ),
                ),
                if (count > 0)
                  Positioned(
                    bottom: 2,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(count > 4 ? 4 : count, (index) {
                        bool isLast = index == (count > 4 ? 4 : count) - 1;
                        return Align(
                          widthFactor: isLast ? 1.0 : 0.6,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: isToday
                                  ? Colors.black54
                                  : Colors.blueAccent,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
