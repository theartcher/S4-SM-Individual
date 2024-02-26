import 'dart:async';
import 'dart:io';

import 'package:microphone_mixer_flutter/utils/file_api.dart';
import 'package:microphone_mixer_flutter/utils/snackbar.dart';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:uuid/uuid.dart';

var UNIQUE_ID = Uuid().v4();
const double iconDefaultSize = 40.00;
const PRIMARY_COLOR = Color(0xFFfd0098);

class MicrophoneRoute extends StatefulWidget {
  const MicrophoneRoute({super.key});

  @override
  State<MicrophoneRoute> createState() => _MicrophoneRouteState();
}

class _MicrophoneRouteState extends State<MicrophoneRoute> {
  final FlutterSoundRecorder recorder = FlutterSoundRecorder();

  bool isRecorderReady = false;
  bool finishedRecording = false;
  File? audioFile;
  String? path;

  TextEditingController urlController = TextEditingController()
    ..text = "ws://box-busy.gl.at.ply.gg:12466";
  WebSocketChannel? channel;

  @override
  void initState() {
    super.initState();
    initRecorder();
    initWebSocket();
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    urlController.dispose();
    channel?.sink.close();
    super.dispose();
  }

  void resetWebSocket() {
    channel = null;
    initWebSocket();
  }

  Future<void> initRecorder() async {
    if (recorder.isRecording) {
      await recorder.stopRecorder();
    }

    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      return snack("Microphone permission not granted.", context,
          snackOption: SnackOptions.warn);
    }

    await recorder.openRecorder();

    setState(() {
      isRecorderReady = true;
    });
  }

  void initWebSocket() async {
    final url = urlController.text.trim();
    final wsUrl = Uri.parse(url);
    channel = WebSocketChannel.connect(wsUrl);

    if (channel == null) {
      return snack(
          "Failed to initialize a proper web-socket. Try resetting it!",
          context,
          snackOption: SnackOptions.warn);
    }

    await channel?.ready;

    channel?.stream.listen((data) {
      handleStreamCommands(data);
    });

    channel?.sink.add('Microphone mode - $UNIQUE_ID');
  }

  void handleStreamCommands(dynamic data) {
    String stringData = data.toString();
    List<String> splitStrings = stringData.split('@');
    String command = splitStrings[0];
    String time = splitStrings[1];
    DateTime commandTime = DateTime.parse(time);

    switch (command) {
      case 'start':
        print('Start: $stringData');
        startRecording(commandTime);
        break;
      case 'stop':
        print('Stop: $stringData');
        stopRecording(commandTime);
        break;
      default:
        snack("Received command was not recognized: '$command'", context,
            snackOption: SnackOptions.warn);
    }
  }

  Future<void> startRecording(DateTime start) async {
    await initRecorder();
    if (!isRecorderReady) {
      return snack(
          "Recorder was not ready when receiving start command", context,
          snackOption: SnackOptions.error);
    }

    while (DateTime.now().isBefore(start)) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    await recorder.startRecorder(toFile: 'audio-$UNIQUE_ID');
  }

  Future<void> stopRecording(DateTime stop) async {
    if (!recorder.isRecording) {
      snack("Fakka je bent niet aan het opnemen G.", context);
      return;
    }

    if (!isRecorderReady) {
      snack("Something went wrong while initializing the recorder.", context,
          snackOption: SnackOptions.error);
      return;
    }

    while (DateTime.now().isBefore(stop)) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    path = await recorder.stopRecorder();
    audioFile = File(path!);

    setState(() {
      finishedRecording = true;

      return snack("Stopped recording.", context,
          snackOption: SnackOptions.succes);
    });

    sendConvertedAudio(audioFile, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Microphone mode'),
        backgroundColor: PRIMARY_COLOR,
      ),
      backgroundColor: Colors.grey.shade900,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                labelStyle:
                    TextStyle(color: Colors.white), // Set label text color
                hintStyle:
                    TextStyle(color: PRIMARY_COLOR), // Set hint text color
              ),
              style: const TextStyle(color: PRIMARY_COLOR), // Set text color
            ),
          ],
        ),
      ),
    );
  }
}
