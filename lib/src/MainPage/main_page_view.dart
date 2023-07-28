import 'package:googleapis/calendar/v3.dart' as calendar;

import 'package:flutter/material.dart';
import '../settings/settings_controller.dart';
import '../settings/settings_view.dart';
import 'calendarHandle.dart';
import 'myCalendar.dart';
import 'sample_item.dart';

//a class to handle calendar stuff with those 3 methods getCalendarApi, getCalendarId, readCalendarMonth

/// Displays a list of SampleItems.
class MainPageView extends StatelessWidget {
  MainPageView({
    super.key,
    this.items = const [SampleItem(1), SampleItem(2), SampleItem(3)],
    required this.controller,
  }) {
    // Create a CalendarHandle object
    handle = CalendarHandle(controller);
  }
  late CalendarHandle handle;

  static const routeName = '/';

  final List<SampleItem> items;

  void createEvent() async {
    var event = calendar.Event(
      description: 'Event name',
      start: calendar.EventDateTime(dateTime: DateTime.now()),
      end: calendar.EventDateTime(
          dateTime: DateTime.now().add(Duration(hours: 1))),
    );

    print(event.toJson());
    // Create object of event
  }

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
    'Tr': {
      'color': Colors.blue,
      'text': 'Trasferta',
      'textColor': Colors.white,
    },
    'A': {
      'color': Colors.grey,
      'text': 'Assenza',
      'textColor': Colors.black,
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
  Widget build(BuildContext context) {
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
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),

      // To work with lists that may contain a large number of items, it's best
      // to use the ListView.builder constructor.
      //
      // In contrast to the default ListView constructor, which requires
      // building all Widgets up front, the ListView.builder constructor lazily
      // builds Widgets as they're scrolled into view.
      // body: ListView.builder(
      //   // Providing a restorationId allows the ListView to restore the
      //   // scroll position when a user leaves and returns to the app after it
      //   // has been killed while running in the background.
      //   restorationId: 'sampleItemListView',
      //   itemCount: items.length,
      //   itemBuilder: (BuildContext context, int index) {
      //     final item = items[index];
      //     return ListTile(
      //         title: Text(controller.isUserLogged
      //             ? 'SampleItem ${item.id}'
      //             : 'is null'),
      //         leading: const CircleAvatar(
      //           // Display the Flutter Logo image asset.
      //           foregroundImage: AssetImage('assets/images/flutter_logo.png'),
      //         ),
      //         onTap: () {
      //           // Navigate to the details page. If the user leaves and returns to
      //           // the app after it has been killed while running in the
      //           // background, the navigation stack is restored.
      //           Navigator.restorablePushNamed(
      //             context,
      //             SampleItemDetailsView.routeName,
      //           );
      //         });
      //   },
      // ),

      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Row(
                  textBaseline: TextBaseline.alphabetic,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  // 20 gennaio 2023 ma gennaio con un font più piccolo e 20 rosso
                  children: [
                    Text(
                      DateTime.now().day.toString(),
                      style: const TextStyle(
                        fontSize: 60,
                        color: Colors.red,
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          months[DateTime.now().month - 1],
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          DateTime.now().year.toString(),
                          style: const TextStyle(
                            fontSize: 30,
                          ),
                        ),
                      ],
                    ),
                  ],
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
                      child: MyCalendar(
                        statusTheme: statusTheme,
                        controller: controller,
                      ),
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
                          value: 'A',
                          items: [
                            for (var stat in statusTheme.keys)
                              DropdownMenuItem(
                                value: stat,
                                child:
                                    Text(statusTheme[stat]?['text'] as String),
                              ),
                          ],
                          onChanged: printHello),
                      const Row(
                        children: [
                          Checkbox(value: false, onChanged: printHello),
                          Text('Part Time'),
                        ],
                      )
                    ],
                  ),
                ),
                const Divider(),
                // mocks permessi generator with choiseble hours start and end
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Permessi',
                          style: TextStyle(
                            fontSize: 20,
                          )),
                      // pluss icon button
                      IconButton(
                          onPressed: () {
                            handle.readCalendarMonth(7, 2023);
                          },
                          icon: Icon(Icons.add))
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
