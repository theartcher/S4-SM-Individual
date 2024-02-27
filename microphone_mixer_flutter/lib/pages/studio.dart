import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:microphone_mixer_flutter/utils/file_api.dart';
import 'package:microphone_mixer_flutter/utils/snackbar.dart';
import 'package:ntp/ntp.dart';
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
  final audioPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  TextEditingController urlController = TextEditingController()
    ..text = "ws://box-busy.gl.at.ply.gg:12466";
  WebSocketChannel? channel;

  late String audioPath = '';
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    initWebSocket();
  }

  @override
  void dispose() {
    urlController.dispose();
    channel?.sink.close();
    audioPlayer.dispose();
    super.dispose();
  }

  void initWebSocket() async {
    final url = urlController.text.trim();
    final wsUrl = Uri.parse(url);
    channel = IOWebSocketChannel.connect(wsUrl);

    if (channel == null) return;

    await channel?.ready;
    channel?.sink.add('Studio mode');

    snack("Initialized new WebSocket.", context,
        snackOption: SnackOptions.success);
  }

  void resetWebSocket() {
    channel = null;
    initWebSocket();
  }

  void getAudio() async {
    var path = await collectMergedAudio(context, GROUP_ID);

    if (path == '' || path == null) {
      snack("Failed to retrieve an audio file.", context,
          snackOption: SnackOptions.error);
    }

    setState(() {
      audioPath = path;
    });

    print("Audio - $audioPath");
    snack("Retrieved an audio file successfully.", context,
        snackOption: SnackOptions.success);
  }

  void sendStart() async {
    var startTime = await NTP.now();
    startTime = startTime.add(const Duration(seconds: 3));
    startTime =
        startTime.subtract(Duration(milliseconds: startTime.millisecond));
    startTime.toIso8601String();
    startTime.toString();
    channel?.sink.add('start@$startTime');
    snack("Sent start command!", context, snackOption: SnackOptions.success);
  }

  void sendStop() async {
    var stopTime = await NTP.now();
    stopTime = stopTime.add(const Duration(seconds: 3));
    stopTime = stopTime.subtract(Duration(milliseconds: stopTime.millisecond));
    stopTime.toIso8601String();
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
              ],
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
            ElevatedButton(
              onPressed: () {
                getAudio();
              },
              child: const Text(
                'Get audio.',
                style: TextStyle(color: PRIMARY_COLOR),
              ),
            ),
            Column(
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
                Container(
                    child: audioPath == ''
                        ? const Text(
                            "Womp womp no file found!",
                            style: TextStyle(color: PRIMARY_COLOR),
                          )
                        : ElevatedButton(
                            child: Text(
                              isPlaying ? 'Pause audio' : 'Play audio',
                              style: TextStyle(color: PRIMARY_COLOR),
                            ),
                            onPressed: () {
                              setState(() {
                                if (isPlaying) {
                                  audioPlayer.stop();
                                } else {
                                  audioPlayer.play(DeviceFileSource(audioPath));
                                }
                                isPlaying = !isPlaying;
                              });
                            },
                          ))
              ],
            ),
          ],
        ),
      );
}
