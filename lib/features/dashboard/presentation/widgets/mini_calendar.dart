import 'package:flutter/material.dart';
import '../../../../common/utils/constants.dart';

/// A navigable month-view calendar: lets the resident move between months and
/// pick any day; highlights the picked day and puts a dot under any day that
/// has at least one visit (from [daysWithVisits], scoped to [displayedMonth]).
class MiniCalendar extends StatelessWidget {
  final DateTime displayedMonth;
  final DateTime selectedDay;
  final Set<int> daysWithVisits;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onDaySelected;

  const MiniCalendar({
    super.key,
    required this.displayedMonth,
    required this.selectedDay,
    required this.onMonthChanged,
    required this.onDaySelected,
    this.daysWithVisits = const {},
  });

  static const _weekdayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  static const _monthNames = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];
  static const _fullWeekdayNames = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo',
  ];

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstOfMonth = DateTime(displayedMonth.year, displayedMonth.month, 1);
    final daysInMonth = DateTime(displayedMonth.year, displayedMonth.month + 1, 0).day;
    // DateTime.weekday: Mon=1..Sun=7 — matches our L..D header directly.
    final leadingBlanks = firstOfMonth.weekday - 1;

    final cells = <int?>[
      ...List.filled(leadingBlanks, null),
      ...List.generate(daysInMonth, (i) => i + 1),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _isSameDay(selectedDay, now)
                    ? '${_fullWeekdayNames[now.weekday - 1]}, ${now.day} de ${_monthNames[now.month - 1]} ${now.year}'
                    : '${_capitalize(_monthNames[displayedMonth.month - 1])} ${displayedMonth.year}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  fontFamily: AppFonts.body,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => onMonthChanged(DateTime(displayedMonth.year, displayedMonth.month - 1, 1)),
              child: const Icon(Icons.chevron_left, color: Colors.white54, size: 20),
            ),
            GestureDetector(
              onTap: () => onMonthChanged(DateTime(displayedMonth.year, displayedMonth.month + 1, 1)),
              child: const Icon(Icons.chevron_right, color: Colors.white54, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: _weekdayLabels
              .map((d) => Expanded(
                    child: Center(
                      child: Text(d,
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 12, fontFamily: AppFonts.label)),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cells.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, i) {
            final day = cells[i];
            if (day == null) return const SizedBox.shrink();
            final cellDate = DateTime(displayedMonth.year, displayedMonth.month, day);
            final isSelected = _isSameDay(cellDate, selectedDay);
            final hasVisit = daysWithVisits.contains(day);
            return GestureDetector(
              onTap: () => onDaySelected(cellDate),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: isSelected
                          ? const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)
                          : null,
                      child: Text(
                        '$day',
                        style: TextStyle(
                          color: isSelected ? AppColors.neutral : Colors.white70,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                          fontFamily: AppFonts.body,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (hasVisit && !isSelected)
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _capitalize(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}
