import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/src/MainPage/main_page_view.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import '../auth/login.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'form_line.dart';
import 'settings_controller.dart';
import 'sign_out_button.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    tz.initializeTimeZones();
    var locations = tz.timeZoneDatabase.locations;
    //get context theme
    var colorScheme = Theme.of(context).colorScheme;
    User? currentUser = FirebaseAuth.instance.currentUser;
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      currentUser = user;
      controller.updateIsUserLogged(user != null);
    });
    final label = 'Hello';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          DropdownButton<ThemeMode>(
            // Read the selected themeMode from the controller
            value: controller.themeMode,
            // Call the updateThemeMode method any time the user selects a theme.
            onChanged: controller.updateThemeMode,
            items: const [
              DropdownMenuItem(
                value: ThemeMode.system,
                child: Text('System Theme'),
              ),
              DropdownMenuItem(
                value: ThemeMode.light,
                child: Text('Light Theme'),
              ),
              DropdownMenuItem(
                value: ThemeMode.dark,
                child: Text('Dark Theme'),
              )
            ],
          ),
          Expanded(
            child: ListView(
                shrinkWrap: true,
                clipBehavior: Clip.antiAlias,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (controller.isUserLogged)
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Part-time percentage:'),
                                  DropdownButton(
                                      value: controller.partTimePercentage,
                                      items: const [
                                        DropdownMenuItem(
                                          value: 50,
                                          child: Text('50%'),
                                        ),
                                        DropdownMenuItem(
                                          value: 75,
                                          child: Text('75%'),
                                        ),
                                        DropdownMenuItem(
                                          value: 100,
                                          child: Text('100%'),
                                        )
                                      ],
                                      onChanged:
                                          controller.updatePartTimePercentage),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Timezone:'),
                                  DropdownButton(
                                      style: TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          color: colorScheme.onSurface),
                                      value: controller.tmzLocation,
                                      items: [
                                        for (var location in locations.keys)
                                          DropdownMenuItem(
                                            value: location,
                                            child: Text(location),
                                          ),
                                      ],
                                      onChanged: controller.updateTmzLocation),
                                ],
                              ),
                              TextField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  labelText: 'Company Name',
                                  labelStyle:
                                      TextStyle(color: colorScheme.onSurface),
                                ),
                              ),
                              //geolocation

                              FormLine(
                                  value: controller.companyName,
                                  label: 'Company Name',
                                  updateFun: controller.updateCompanyName),
                              FormLine(
                                  value: controller.companyAddress,
                                  label: 'Company Address',
                                  updateFun: controller.updateCompanyAddress),
                            ],
                          ),
                        const SizedBox(height: 10),
                        if (currentUser == null)
                          (SignInButton(
                            Buttons.Google,
                            onPressed: signInWithGoogle,
                          ))
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Logout (${currentUser?.email ?? 'User'})'),
                              SignOutButton(
                                onPressed: FirebaseAuth.instance.signOut,
                              )
                            ],
                          ),
                        ElevatedButton(
                            style: ButtonStyle(),
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, MainPageView.routeName);
                            },
                            child: Text('Go Back'))
                      ],
                    ),
                  ),
                ]),
          ),
        ],
      ),
    );
  }
}

void printHello(dynamic? any) {
  print('Hello');
}

void printHello2() {
  print('Hello');
}
