import 'package:flutter/material.dart';
export 'snackbar.dart';

enum SnackOptions { info, success, warn, error }

void snack(String toastMessage, BuildContext context,
    {SnackOptions snackOption = SnackOptions.info,
    int milliSecondsToShow = 1000}) {
  var bgColor = Colors.white;
  var textColor = Colors.black;

  switch (snackOption) {
    case SnackOptions.info:
      bgColor = Colors.transparent;
      textColor = Colors.white;
      break;
    case SnackOptions.success:
      bgColor = const Color(0xFFBFFFC6);
      textColor = Colors.black;
      break;
    case SnackOptions.warn:
      bgColor = const Color(0xFFE7FFAC);
      textColor = Colors.black;
      break;
    case SnackOptions.error:
      bgColor = const Color(0xFFFFABAB);
      textColor = Colors.black;
      break;
    default:
      bgColor = Colors.transparent;
      textColor = Colors.black;
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(toastMessage, style: TextStyle(color: textColor)),
      duration: Duration(milliseconds: milliSecondsToShow),
      elevation: 0,
      backgroundColor: bgColor,
    ),
  );
}
