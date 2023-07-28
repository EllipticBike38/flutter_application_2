import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../settings/settings_controller.dart';
import '../settings/settings_view.dart';
import 'calendarHandle.dart';
import 'sample_item.dart';

class MyCalendar extends StatefulWidget {
  MyCalendar({
    super.key,
    required this.statusTheme,
    required this.controller,
  }) {
    // Create a CalendarHandle object
    handle = CalendarHandle(controller);
  }
  late CalendarHandle handle;
  final SettingsController controller;
  final Map<String, Map<String, Object>> statusTheme;

  @override
  State<MyCalendar> createState() => _MyCalendarState();

  // async read calendar from handle function
}

class _MyCalendarState extends State<MyCalendar> {
  @override
  Widget build(BuildContext context) {
    //get handler
    CalendarHandle handle = widget.handle;
    final Future<dynamic> events = handle.readCalendarMonth(7, 2023);
    return FutureBuilder<dynamic>(
      future: events,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return TableCalendar(
            shouldFillViewport: true,
            focusedDay: DateTime.now().toLocal(),
            firstDay: DateTime(2000),
            lastDay: DateTime(2028),
            startingDayOfWeek: StartingDayOfWeek.monday,
            locale: 'it_IT',
            availableCalendarFormats: Map.from({
              CalendarFormat.month: 'Month',
            }),
            calendarBuilders: CalendarBuilders(
              todayBuilder: (context, day, focusedDay) => Center(
                child: Container(
                  alignment: Alignment.center,
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange, width: 3),
                    color: day.weekday == DateTime.saturday ||
                            day.weekday == DateTime.sunday
                        ? Colors.red
                        : (snapshot.data)
                                .keys
                                .contains(day.toLocal().toString())
                            ? (widget.statusTheme[
                                (snapshot.data)[day.toLocal().toString()]
                                    ['type']]?['color'] as Color)
                            : widget.statusTheme['A']?['color'] as Color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    day.day.toString(),
                    style: TextStyle(
                      color: day.weekday == DateTime.saturday ||
                              day.weekday == DateTime.sunday
                          ? Colors.white
                          : (snapshot.data)
                                  .keys
                                  .contains(day.toLocal().toString())
                              ? (widget.statusTheme[
                                  (snapshot.data)[day.toLocal().toString()]
                                      ['type']]?['textColor'] as Color)
                              : widget.statusTheme['A']?['textColor'] as Color,
                    ),
                  ),
                ),
              ),
              defaultBuilder: (context, day, focusedDay) => Center(
                child: Container(
                  alignment: Alignment.center,
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: day.weekday == DateTime.saturday ||
                            day.weekday == DateTime.sunday
                        ? Colors.red
                        : (snapshot.data)
                                .keys
                                .contains(day.toLocal().toString())
                            ? (widget.statusTheme[
                                (snapshot.data)[day.toLocal().toString()]
                                    ?['type']]?['color'] as Color)
                            : widget.statusTheme['A']?['color'] as Color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    day.day.toString(),
                    style: TextStyle(
                      color: day.weekday == DateTime.saturday ||
                              day.weekday == DateTime.sunday
                          ? Colors.white
                          : (snapshot.data)
                                  .keys
                                  .contains(day.toLocal().toString())
                              ? (widget.statusTheme[
                                  (snapshot.data)[day.toLocal().toString()]
                                      ?['type']]?['textColor'] as Color)
                              : widget.statusTheme['A']?['textColor'] as Color,
                    ),
                  ),
                ),
              ),
              dowBuilder: (context, day) {
                if (day.weekday == DateTime.saturday ||
                    day.weekday == DateTime.sunday) {
                  final text = DateFormat.E('it_IT').format(day);

                  return Center(
                    child: Text(
                      text,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
              },
            ),
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
