import 'package:flutter/material.dart';

class CalendarDayWidget extends StatelessWidget {
  final DateTime currentDay;
  final bool isSelected;
  final bool isToday;
  final bool isCurrentMonth;
  final Map<DateTime, ({int count, Color color})>? events;
  final bool disableDaysWithoutEvents;
  final VoidCallback? onTap;

  const CalendarDayWidget({
    super.key,
    required this.currentDay,
    this.isSelected = false,
    this.isToday = false,
    required this.isCurrentMonth,
    this.events,
    this.disableDaysWithoutEvents = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    int count = 0;
    Color eventColor = Colors.blueAccent;

    if (isCurrentMonth && events != null) {
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

    final bool hasEvents = count > 0;
    final bool isEnabled =
        isCurrentMonth && (!disableDaysWithoutEvents || hasEvents);
    final bool effectivelySelected = isEnabled && isSelected;

    return Expanded(
      child: GestureDetector(
        onTap: isEnabled ? onTap : null,
        behavior: isEnabled ? HitTestBehavior.opaque : HitTestBehavior.deferToChild,
        child: Center(
          child: Container(
            width: 45,
            height: 45,
            decoration: effectivelySelected
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
                    fontWeight:
                        effectivelySelected ? FontWeight.bold : FontWeight.normal,
                    color: isEnabled
                        ? (effectivelySelected ? Colors.black : null)
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
                              color: effectivelySelected
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
