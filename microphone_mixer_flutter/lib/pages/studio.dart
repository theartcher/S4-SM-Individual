import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:microphone_mixer_flutter/pages/microphone.dart';

class StudioRoute extends StatefulWidget {
  const StudioRoute({super.key});

  @override
  State<StudioRoute> createState() => _StudioRouteState();
}

class _StudioRouteState extends State<StudioRoute> {
  final audioPlayer = AudioPlayer();
  late final FlutterSoundRecorder recorder;
  bool isPlaying = false;
  bool isRecorderReady = false;
  late File? audioFile;
  late String? path;

  @override
  void initState() {
    super.initState();
    recorder = FlutterSoundRecorder();
    initRecorder();
  }

  @override
  void dispose() {
    recorder.closeRecorder();

    super.dispose();
  }

  Future<void> initRecorder() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw "Microphone permission not granted";
    }

    await recorder.openRecorder();

    setState(() {
      isRecorderReady = true;
    });
  }

  Future<void> recordAudio() async {
    if (!isRecorderReady) {
      print("Is recorder ready? $isRecorderReady");
      return;
    }

    await recorder.startRecorder(toFile: 'audio');
  }

  Future<void> stopRecording() async {
    if (!isRecorderReady) {
      print("Is recorder ready? $isRecorderReady");
      return;
    }

    path = await recorder.stopRecorder();
    audioFile = File(path!);

    print("Recorded audio @: $audioFile");
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
              child: Text('Go to Second Page'),
            ),
            Center(
              child: ElevatedButton(
                child: Icon(
                  recorder.isRecording ? Icons.stop : Icons.mic,
                  size: 80,
                ),
                onPressed: () async {
                  if (recorder.isRecording) {
                    await stopRecording();
                  } else {
                    await recordAudio();
                  }
                  setState(() {});
                },
              ),
            ),
            CircleAvatar(
              radius: 35,
              child: IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                iconSize: 50,
                onPressed: () async {
                  if (path == 'Null' || path == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            "You have not yet recorded any audio to play."),
                        duration: Duration(seconds: 1),
                      ),
                    );
                    return;
                  }

                  if (isPlaying) {
                    await audioPlayer.stop();
                  } else {
                    await audioPlayer.play(DeviceFileSource(path!));
                  }
                },
              ),
            )
          ],
        ),
      );
}
