import 'package:flutter/material.dart';
import 'package:microphone_mixer_flutter/pages/studio.dart';
import 'package:microphone_mixer_flutter/pages/connectivityTest.dart';

void main() {
  runApp(const MaterialApp(
    title: 'Yippie, routing!',
    home: ConnectivityRoute(),
  ));
}
