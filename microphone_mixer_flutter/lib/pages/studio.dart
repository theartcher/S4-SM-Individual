import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:microphone_mixer_flutter/pages/microphone.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class StudioRoute extends StatefulWidget {
  const StudioRoute({super.key});

  @override
  State<StudioRoute> createState() => _StudioRouteState();
}

class _StudioRouteState extends State<StudioRoute> {
  final audioPlayer = AudioPlayer();
  TextEditingController urlController = TextEditingController()
    ..text = "ws://box-busy.gl.at.ply.gg:12466";
  WebSocketChannel? channel;

  @override
  void initState() {
    super.initState();
    initWebSocket();
  }

  @override
  void dispose() {
    urlController.dispose();
    channel?.sink.close();
    super.dispose();
  }

  void initWebSocket() async {
    final url = urlController.text.trim();
    final wsUrl = Uri.parse(url);
    channel = IOWebSocketChannel.connect(wsUrl);

    if (channel == null) {
      print("Websocket channel is null!");
    }

    await channel?.ready;
  }

  void sendStart() async {
    var startTime = DateTime.now().add(const Duration(seconds: 3));
    startTime.toString();
    channel?.sink.add('start@$startTime');
  }

  void sendStop() async {
    var stopTime = DateTime.now().add(const Duration(seconds: 3));
    stopTime.toString();

    channel?.sink.add('stop@$stopTime');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.grey.shade900,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MicrophoneRoute()),
                );
              },
              child: const Text('Go to Second Page'),
            ),
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                labelText: 'WebSocket URL',
                hintText: 'Enter WebSocket URL',
                fillColor: Colors.purple.shade200,
                labelStyle:
                    TextStyle(color: Colors.white), // Set label text color
                hintStyle:
                    TextStyle(color: Colors.white), // Set hint text color
              ),
              style: TextStyle(color: Colors.purple), // Set text color
            ),
            ElevatedButton(
              onPressed: () {
                sendStart();
              },
              child: const Text('Websocket ping.'),
            ),
          ],
        ),
      );
}
