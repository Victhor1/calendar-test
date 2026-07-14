import 'package:flutter/material.dart';

class CalendarDayWidget extends StatelessWidget {
  final DateTime currentDay;
  final bool isToday;
  final bool isCurrentMonth;
  final Map<DateTime, ({int count, Color color})>? events;
  final VoidCallback? onTap;

  const CalendarDayWidget({
    super.key,
    required this.currentDay,
    required this.isToday,
    required this.isCurrentMonth,
    this.events,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    int count = 0;
    Color eventColor = Colors.blueAccent;

    if (events != null) {
      DateTime key = DateTime(
        currentDay.year,
        currentDay.month,
        currentDay.day,
      );
      if (events!.containsKey(key)) {
        count = events![key]!.count;
        eventColor = events![key]!.color;
      }
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
                                  ? eventColor.withValues(alpha: 0.8)
                                  : eventColor,
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
