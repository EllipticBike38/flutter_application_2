import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../settings/settings_controller.dart';
import 'calendarHandle.dart';

String easterSunday(int year, {bool monday = false}) {
  num g = year % 19;
  num c = year / 100;
  num h =
      (c - (c / 4).floor() - ((8 * c + 13) / 25).floor() + 19 * g + 15) % 30;
  num i = h -
      (h / 28).floor() *
          (1 - (h / 28).floor() * (29 / (h + 1)).floor() * ((21 - g) / 11));

  int day =
      (i - ((year + (year / 4).floor() + i + 2 - c + (c / 4).floor()) % 7) + 28)
          .toInt();
  monday ? day++ : day;
  int month = 3;

  if (day > 31) {
    month++;
    day -= 31;
  }

  return '${day < 10 ? "0" : ""}$day-${month < 10 ? "0" : ""}$month';
}

class MyCalendar extends StatefulWidget {
  MyCalendar({
    super.key,
    required this.statusTheme,
    required this.controller,
    required this.updateToday,
    required this.calendarHandle,
    required this.updateEvents,
    required this.events,
  }) {}
  Map<String?, Map<String, Object?>> events;
  Function(int, int) updateEvents;

  CalendarHandle calendarHandle;

  void Function(DateTime) updateToday;
  final SettingsController controller;
  final Map<String, Map<String, Object>> statusTheme;
  static var festivities = [
    '01-01',
    '06-01',
    '25-04',
    '01-05',
    '02-06',
    '15-08',
    '01-11',
    '08-12',
    '25-12',
    '26-12',
    easterSunday(DateTime.now().year),
    easterSunday(DateTime.now().year, monday: true),
  ];
  static bool isHoliday(DateTime day, {bool isFestivity = false}) {
    return day.weekday == DateTime.saturday ||
        day.weekday == DateTime.sunday ||
        (isFestivity &&
            MyCalendar.festivities.contains(
                '${day.day < 10 ? "0" : ""}${day.day}-${day.month < 10 ? "0" : ""}${day.month}'));
  }

  @override
  State<MyCalendar> createState() => _MyCalendarState();

  // async read calendar from handle function
}

class _MyCalendarState extends State<MyCalendar> {
  DateTime focusedDayState = DateTime(DateTime.now().toLocal().year,
      DateTime.now().toLocal().month, DateTime.now().toLocal().day);

  updateFocusedDay(DateTime day) {
    setState(() {
      widget.updateToday(day);
      focusedDayState = day;
    });
  }

  @override
  Widget build(BuildContext context) {
    //get handler

    dayBuilder(isToday) {
      return (context, day, focusedDay) => Center(
            child: Container(
              alignment: Alignment.center,
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                border:
                    isToday ? Border.all(color: Colors.orange, width: 3) : null,
                color: (widget.events)
                        .keys
                        .contains(day.toString().substring(0, 10))
                    ? (widget.statusTheme[(widget
                            .events)[day.toString().substring(0, 10)]!['type']]
                        ?['color'] as Color)
                    : MyCalendar.isHoliday(day, isFestivity: true)
                        ? Colors.red
                        : widget.statusTheme['A']?['color'] as Color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                day.day.toString(),
                style: TextStyle(
                  color: MyCalendar.isHoliday(day, isFestivity: true)
                      ? Colors.white
                      : (widget.events)
                              .keys
                              .contains(day.toString().substring(0, 10))
                          ? (widget.statusTheme[(widget.events)[
                                  day.toString().substring(0, 10)]!['type']]
                              ?['textColor'] as Color)
                          : widget.statusTheme['A']?['textColor'] as Color,
                ),
              ),
            ),
          );
    }

    return TableCalendar(
      shouldFillViewport: true,
      focusedDay: focusedDayState,
      firstDay: DateTime(2000),
      lastDay: DateTime(2028),
      startingDayOfWeek: StartingDayOfWeek.monday,
      locale: 'it_IT',
      onPageChanged: (focusedDay) => {
        widget.updateEvents(
            focusedDay.toLocal().year, focusedDay.toLocal().month),
        updateFocusedDay(focusedDay)
      },
      onDaySelected: (selectedDay, focusedDay) =>
          {updateFocusedDay(selectedDay)},
      availableCalendarFormats: Map.from({
        CalendarFormat.month: 'Month',
      }),
      calendarBuilders: CalendarBuilders(
        todayBuilder: dayBuilder(true),
        defaultBuilder: dayBuilder(false),
        dowBuilder: (context, day) {
          final text = DateFormat.E('it_IT').format(day);

          return Center(
            child: Text(
              text,
              style: TextStyle(
                  color: MyCalendar.isHoliday(day, isFestivity: false)
                      ? Colors.red
                      : Theme.of(context).colorScheme.onSurface),
            ),
          );
        },
      ),
    );
  }
}
