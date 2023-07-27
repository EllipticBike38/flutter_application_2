import 'package:flutter/material.dart';

import '../settings/settings_controller.dart';
import '../settings/settings_view.dart';
import 'sample_item.dart';
import 'sample_item_details_view.dart';

/// Displays a list of SampleItems.
class MainPageView extends StatelessWidget {
  const MainPageView({
    super.key,
    this.items = const [SampleItem(1), SampleItem(2), SampleItem(3)],
    required this.controller,
  });

  static const routeName = '/';

  final List<SampleItem> items;

  final SettingsController controller;

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
                const Row(
                  textBaseline: TextBaseline.alphabetic,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  // 20 gennaio 2023 ma gennaio con un font più piccolo e 20 rosso
                  children: [
                    Text(
                      '20',
                      style: TextStyle(
                        fontSize: 60,
                        color: Colors.red,
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          ' GENNAIO ',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          '2023',
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton<String>(
                          value: 'A',
                          items: const [
                            // Sw, Ps, Pe, Mt, Fe, Tr, A
                            DropdownMenuItem(
                              value: 'Sw',
                              child: Text('Smartworking'),
                            ),
                            DropdownMenuItem(
                              value: 'Ps',
                              child: Text('Presenza'),
                            ),
                            DropdownMenuItem(
                              value: 'Pe',
                              child: Text('Permesso'),
                            ),
                            DropdownMenuItem(
                              value: 'Mt',
                              child: Text('Malattia'),
                            ),
                            DropdownMenuItem(
                              value: 'Fe',
                              child: Text('Ferie'),
                            ),
                            DropdownMenuItem(
                              value: 'Tr',
                              child: Text('Trasferta'),
                            ),
                            DropdownMenuItem(
                              value: 'A',
                              child: Text('Assenza'),
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
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
