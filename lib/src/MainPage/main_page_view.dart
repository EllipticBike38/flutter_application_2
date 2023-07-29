import 'package:flutter/material.dart';
import '../settings/settings_controller.dart';
import '../settings/settings_view.dart';
import 'calendarHandle.dart';
import 'date_title.dart';
import 'myCalendar.dart';
import 'sample_item.dart';

class MainPageView extends StatefulWidget {
  const MainPageView({
    super.key,
    this.items = const [SampleItem(1), SampleItem(2), SampleItem(3)],
    required this.controller,
    required this.calendarHandle,
  });

  final CalendarHandle calendarHandle;

  static const routeName = '/';

  final List<SampleItem> items;

  static var statusTheme = {
    'Sw': {
      'color': Colors.blue,
      'text': 'Smartworking',
      'textColor': Colors.white,
    },
    'Ps': {
      'color': Colors.green,
      'text': 'Presenza',
      'textColor': Colors.white,
    },
    'Pe': {
      'color': Colors.red.shade300,
      'text': 'Permesso',
      'textColor': Colors.white,
    },
    'Mt': {
      'color': Colors.red.shade300,
      'text': 'Malattia',
      'textColor': Colors.white,
    },
    'Fe': {
      'color': Colors.red.shade300,
      'text': 'Ferie',
      'textColor': Colors.white,
    },
    'A': {
      'color': Colors.grey,
      'text': 'Assenza',
      'textColor': Colors.black,
    },
    'Tr': {
      'color': Colors.blue,
      'text': 'Trasferta',
      'textColor': Colors.white,
    },
    'Vc': {
      'color': Colors.red,
      'text': 'Festività',
      'textColor': Colors.white,
    },
  };

  final SettingsController controller;

  static const months = [
    'GENNAIO',
    'FEBBRAIO',
    'MARZO',
    'APRILE',
    'MAGGIO',
    'GIUGNO',
    'LUGLIO',
    'AGOSTO',
    'SETTEMBRE',
    'OTTOBRE',
    'NOVEMBRE',
    'DICEMBRE'
  ];

  @override
  State<MainPageView> createState() => _MainPageViewState();
}

class _MainPageViewState extends State<MainPageView> {
  DateTime selectedDate = DateTime(DateTime.now().toLocal().year,
      DateTime.now().toLocal().month, DateTime.now().toLocal().day);

  List<Map<String, Object?>> dateData = [];

  static var statusThemeKeys = MainPageView.statusTheme.keys;

  void updateDateData() {
    widget.calendarHandle.readCalendarDay(selectedDate).then((value) {
      setState(() {
        dateData = value;
        statusThemeKeys = MainPageView.statusTheme.keys.where((element) =>
            isHoliday(selectedDate)
                ? element == 'Vc' || element == 'Tr'
                : element != 'Vc');
      });
    });
  }

  @override
  void initState() {
    super.initState();
    updateEvents(selectedDate.year, selectedDate.month);
    updateDateData();
  }

  bool initialized = false;

  Map<String?, Map<String, Object?>> events = {};

  void updateEvents(int year, int month) {
    widget.calendarHandle
        .readCalendarMonth(month, year)
        .then((value) => setState(() {
              if (value == null) {
                events = {};
              } else {
                events = value[0];
              }
            }));
  }

  void updateSelectedDate(DateTime day) {
    setState(() {
      statusThemeKeys = MainPageView.statusTheme.keys;
      selectedDate = day;
      updateDateData();
    });
  }

  bool isHoliday(DateTime day) {
    return day.weekday == DateTime.saturday ||
        day.weekday == DateTime.sunday ||
        MyCalendar.festivities.contains(
            '${day.day < 10 ? "0" : ""}${day.day}-${day.month < 10 ? "0" : ""}${day.month}');
  }

  @override
  Widget build(BuildContext context) {
    MyCalendar calendarWidget = MyCalendar(
      calendarHandle: widget.calendarHandle,
      statusTheme: MainPageView.statusTheme,
      controller: widget.controller,
      updateToday: updateSelectedDate,
      updateEvents: updateEvents,
      events: events,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.pushReplacementNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                DateTitle(
                  months: MainPageView.months,
                  selectedDate: selectedDate,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.width < 400
                          ? MediaQuery.of(context).size.width
                          : 400,
                      width: MediaQuery.of(context).size.width < 400
                          ? MediaQuery.of(context).size.width
                          : 400,
                      child: calendarWidget,
                    ),
                    // Spacer()
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton<String>(
                          value: dateData.isEmpty
                              ? (isHoliday(selectedDate) ? 'Vc' : 'A')
                              : (dateData[0]['type'] ??
                                      (isHoliday(selectedDate) ? 'Vc' : 'A'))
                                  as String,
                          items: [
                            for (var stat in statusThemeKeys)
                              DropdownMenuItem(
                                value: stat,
                                child: Text(MainPageView.statusTheme[stat]
                                    ?['text'] as String),
                              ),
                          ],
                          onChanged: (value) {
                            var Pt = true;
                            if (dateData[0].isNotEmpty) {
                              Pt = (dateData[0]['end'] as DateTime)
                                      .difference(
                                          dateData[0]['start'] as DateTime)
                                      .inHours <
                                  8;
                            }
                            widget.calendarHandle
                                .createEvent(selectedDate, value as String, Pt)
                                .then((value) {
                              updateEvents(
                                  selectedDate.year, selectedDate.month);
                              updateDateData();
                            });
                          }),
                      if (widget.controller.partTimePercentage != 100 &&
                          dateData.isNotEmpty &&
                          dateData[0].isNotEmpty)
                        Row(
                          children: [
                            Checkbox(value: () {
                              var i = (dateData[0]['end'] as DateTime)
                                  .difference(dateData[0]['start'] as DateTime);
                              return i.inHours < 8;
                            }(), onChanged: (value) {
                              widget.calendarHandle
                                  .createEvent(
                                      selectedDate,
                                      dateData[0]['type'] as String,
                                      value ?? false)
                                  .then((value) {
                                updateEvents(
                                    selectedDate.year, selectedDate.month);
                                // updateDateData();
                              });
                              ;
                            }),
                            const Text('Part Time'),
                          ],
                        )
                      else
                        const Spacer()
                    ],
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Permessi',
                          style: TextStyle(
                            fontSize: 20,
                          )),
                      // pluss icon button
                      IconButton(
                          onPressed: () {
                            widget.calendarHandle.readCalendarMonth(7, 2023);
                          },
                          icon: const Icon(Icons.add))
                    ],
                  ),
                ),

                // list out permessi, mocks one

                const ListTile(
                  title: Text('Permesso'),
                  subtitle: Text('8:00 - 12:00'),
                  trailing: IconButton(
                      onPressed: printHello2, icon: Icon(Icons.delete)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
