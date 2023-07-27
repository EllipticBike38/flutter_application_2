import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import '../auth/login.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'settings_controller.dart';

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
            child: Padding(
              padding: const EdgeInsets.all(16),
              // Glue the SettingsController to the theme selection DropdownButton.
              //
              // When a user selects a theme from the dropdown list, the
              // SettingsController is updated, which rebuilds the MaterialApp.
              child: ListView(
                shrinkWrap: true,
                clipBehavior: Clip.antiAlias,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          onChanged: controller.updatePartTimePercentage),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      labelStyle: TextStyle(color: colorScheme.onSurface),
                    ),
                  ),
                  //geolocation
                  TextField(
                    decoration: InputDecoration(
                      labelStyle: TextStyle(color: colorScheme.onSurface),
                      border: InputBorder.none,
                      labelText: 'Company Address',
                    ),
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
                      onPressed: () {},
                      child: Text('Save'))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SignOutButton extends StatelessWidget {
  final Function? onPressed;

  const SignOutButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // return MaterialButton(
    //     elevation: 2.0,
    //     key: const ValueKey("Google"),
    //     textColor: const Color(0xFFFFFFFF),
    //     onPressed: FirebaseAuth.instance.signOut,
    //     highlightColor: Colors.white30,
    //     splashColor: Colors.white30,
    //     shape: ButtonTheme.of(context).shape,
    //     height: 36.0,
    //     child: const SizedBox(
    //         width: 35.0,
    //         height: 35.0,
    //         child: Image(
    //           image: AssetImage(
    //             'assets/logos/google_light.png',
    //             package: 'flutter_signin_button',
    //           ),
    //         )));
    return SignInButtonBuilder(
        elevation: 2,
        key: const ValueKey("GitHub"),
        mini: true,
        text: '',
        image: const SizedBox(
            width: 35.0,
            height: 35.0,
            child: Image(
              image: AssetImage(
                'assets/logos/google_light.png',
                package: 'flutter_signin_button',
              ),
            )),
        backgroundColor: const Color(0x00444444),
        onPressed: onPressed ?? signOutGoogle,
        padding: const EdgeInsets.all(0),
        shape: ButtonTheme.of(context).shape);
  }
}

void printHello(dynamic? any) {
  print('Hello');
}

void printHello2() {
  print('Hello');
}
