import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:microphone_mixer_flutter/utils/snackbar.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const PRIMARY_COLOR = Color(0xFFfd0098);
const GROUP_ID = "837238";

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

    if (channel == null) return;

    await channel?.ready;
    channel?.sink.add('Studio mode');
  }

  void resetWebSocket() {
    channel = null;
    initWebSocket();
  }

  void sendStart() async {
    var startTime = DateTime.now().add(const Duration(seconds: 3));
    startTime.toString();
    channel?.sink.add('start@$startTime');
    snack("Sent start command!", context, snackOption: SnackOptions.success);
  }

  void sendStop() async {
    var stopTime = DateTime.now().add(const Duration(seconds: 3));
    stopTime.toString();
    channel?.sink.add('stop@$stopTime');
    snack("Sent stop command!", context, snackOption: SnackOptions.success);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: PRIMARY_COLOR,
          title: const Text('Studio mode'),
        ),
        backgroundColor: Colors.grey.shade900,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(GROUP_ID != '' ? GROUP_ID : "No group set!",
                style: TextStyle(color: PRIMARY_COLOR, fontSize: 50)),
            ElevatedButton(
              onPressed: () {
                sendStart();
              },
              child: const Text(
                'Start recording.',
                style: TextStyle(color: PRIMARY_COLOR),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                sendStop();
              },
              child: const Text(
                'Stop recording.',
                style: TextStyle(color: PRIMARY_COLOR),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                resetWebSocket();
              },
              child: const Text(
                'Reset websocket connection.',
                style: TextStyle(color: PRIMARY_COLOR),
              ),
            ),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'WebSocket URL',
                hintText: 'Enter WebSocket URL',
                fillColor: PRIMARY_COLOR,
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: const TextStyle(color: PRIMARY_COLOR),
            ),
          ],
        ),
      );
}
