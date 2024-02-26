import 'package:flutter/material.dart';
export '_snackbar.dart';

enum ToastOptions { info, succes, warn, error }

void snack(String toastMessage, BuildContext context,
    {ToastOptions toastOption = ToastOptions.info}) {
  var bgColor = Colors.transparent;

  switch (toastOption) {
    case ToastOptions.info:
      bgColor = Colors.transparent;
      break;
    case ToastOptions.succes:
      bgColor = const Color.fromARGB(255, 98, 199, 101);
      break;
    case ToastOptions.warn:
      bgColor = const Color.fromARGB(255, 167, 150, 0);
      break;
    case ToastOptions.error:
      bgColor = const Color.fromARGB(255, 226, 110, 102);
      break;
    default:
      bgColor = Colors.transparent;
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(toastMessage),
      duration: const Duration(seconds: 2),
      elevation: 0,
      backgroundColor: bgColor,
    ),
  );
}
