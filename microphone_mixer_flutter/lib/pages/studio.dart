import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
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

    if (channel == null) return;

    await channel?.ready;
  }

  void resetWebSocket() {
    channel = null;
    initWebSocket();
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
                sendStart();
              },
              child: const Text('Start recording.'),
            ),
            ElevatedButton(
              onPressed: () {
                sendStop();
              },
              child: const Text('Stop recording.'),
            ),
            ElevatedButton(
              onPressed: () {
                resetWebSocket();
              },
              child: const Text('Reset websocket connection.'),
            ),
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                labelText: 'WebSocket URL',
                hintText: 'Enter WebSocket URL',
                fillColor: Colors.purple.shade200,
                labelStyle: const TextStyle(color: Colors.white),
              ),
              style: const TextStyle(color: Colors.purple),
            ),
          ],
        ),
      );
}
