import 'dart:async';
import 'dart:io';

import 'package:microphone_mixer_flutter/utils/file_api.dart';
import 'package:microphone_mixer_flutter/utils/snackbar.dart';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:uuid/uuid.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ntp/ntp.dart';

var UNIQUE_ID = const Uuid().v4();
const double iconDefaultSize = 40.00;
const PRIMARY_COLOR = Color(0xFFfd0098);

class MicrophoneRoute extends StatefulWidget {
  const MicrophoneRoute({super.key});

  @override
  State<MicrophoneRoute> createState() => _MicrophoneRouteState();
}

class _MicrophoneRouteState extends State<MicrophoneRoute> {
  final recorder = AudioRecorder();

  bool isRecording = false;
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
    recorder.dispose();
    urlController.dispose();
    channel?.sink.close();
    super.dispose();
  }

  void resetWebSocket() {
    channel = null;
    initWebSocket();
  }

  Future<void> initRecorder() async {
    if (await recorder.isRecording()) {
      await recorder.stop();
    }

    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      return snack("Microphone permission not granted.", context,
          snackOption: SnackOptions.warn);
    }

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
      String stringData = data.toString();
      List<String> splitStrings = stringData.split('@');
      String command = splitStrings[0];
      String time = splitStrings[1];
      DateTime commandTime = DateTime.parse(time);

      switch (command) {
        case 'start':
          snack("Received start command", context,
              snackOption: SnackOptions.success);
          startRecording(commandTime);
          break;
        case 'stop':
          snack("Received stop command", context,
              snackOption: SnackOptions.success);
          stopRecording(commandTime);
          break;
        default:
          snack("Received command was not recognized: '$stringData'", context,
              snackOption: SnackOptions.warn);
      }
    });

    channel?.sink.add('Microphone mode - $UNIQUE_ID');
  }

  Future<void> startRecording(DateTime start) async {
    await initRecorder();
    if (isRecording) {
      return snack("You are already recording.", context,
          snackOption: SnackOptions.error);
    }

    if (!isRecorderReady) {
      return snack(
          "Recorder was not ready when receiving start command", context,
          snackOption: SnackOptions.error);
    }

    // Calculate time difference
    DateTime now = await NTP.now();
    Duration difference = start.difference(now);

    if (difference.isNegative) {
      return snack("Cannot start recording in the past.", context,
          snackOption: SnackOptions.error);
    }

    // Wait until the exact time
    await Future.delayed(difference);

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;

    await recorder.start(const RecordConfig(),
        path: '$appDocPath/audio-$UNIQUE_ID.m4a');

    snack("Started recording @ ${DateTime.now().toString()}", context,
        snackOption: SnackOptions.success);

    setState(() {
      isRecording = true;
    });
  }

  Future<void> stopRecording(DateTime stop) async {
    if (!await recorder.isRecording()) {
      snack("You are not currently recording.", context,
          snackOption: SnackOptions.warn);
      return;
    }

    if (!isRecorderReady) {
      snack("Something went wrong while initializing the recorder.", context,
          snackOption: SnackOptions.error);
      return;
    }

    // Calculate time difference
    DateTime now = await NTP.now();
    Duration difference = stop.difference(now);

    if (difference.isNegative) {
      return snack("Cannot stop recording in the past.", context,
          snackOption: SnackOptions.error);
    }

    // Wait until the exact time
    await Future.delayed(difference);

    path = await recorder.stop();
    audioFile = File(path!);

    setState(() {
      finishedRecording = true;
      isRecording = false;
    });

    snack("Stopped recording.", context, snackOption: SnackOptions.success);
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
