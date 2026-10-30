import 'package:flutter/material.dart';

class AppSnackBar {
  const new _();

  static void show(BuildContext context, String message) =>
      showWith(ScaffoldMessenger.of(context), message);

  static void showWith(ScaffoldMessengerState messenger, String message) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
