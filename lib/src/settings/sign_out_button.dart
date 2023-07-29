import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import '../auth/login.dart';

class SignOutButton extends StatelessWidget {
  final Function? onPressed;

  const SignOutButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
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
