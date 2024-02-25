import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:microphone_mixer_flutter/pages/microphone.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';

class MicrophoneRoute extends StatefulWidget {
  const MicrophoneRoute({super.key});

  @override
  State<MicrophoneRoute> createState() => _MicrophoneRouteState();
}

class _MicrophoneRouteState extends State<MicrophoneRoute> {
  final recorder = FlutterSoundRecorder();
  final iconDefaultSize = 40.toDouble();

  bool isPlaying = false;
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
    initWebsocket();
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    urlController.dispose();
    channel?.sink.close();
    super.dispose();
  }

  void _toast(var toastMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(toastMessage),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void initWebsocket() async {
    final url = urlController.text.trim();
    final wsUrl = Uri.parse(url);
    channel = WebSocketChannel.connect(wsUrl);

    if (channel == null) {
      print("Websocket channel is null!");
    }

    await channel?.ready;

    channel?.stream.listen((data) {
      var stringData = data.toString();
      var splitStrings = stringData.split('@')[0];
      var command = splitStrings[0];
      var time = splitStrings[1];

      switch (command) {
        case 'start':
          break;
        case 'stop':
          break;
        default:
          _toast("Received command was not recognized. $command");
      }
    });

    channel?.sink.add('Flutter');
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

  Future<void> recordAudio(DateTime start) async {
    if (!isRecorderReady) {
      print("Is recorder ready? $isRecorderReady");
      return;
    }

    final DateTime now = DateTime.now();
    if (now.isAfter(start) || now.isAtSameMomentAs(start)) {
      await recorder.startRecorder(toFile: 'recorded-audio-$now');
    }
  }

  Future<void> stopRecording() async {
    if (!isRecorderReady) {
      print("Is recorder ready? $isRecorderReady");
      return;
    }

    path = await recorder.stopRecorder();
    audioFile = File(path!);

    print("Recorded audio @: $audioFile");

    setState(() {
      finishedRecording = true;
    });

    sendConvertedAudio(audioFile);
  }

  void sendConvertedAudio(File? audioFile) async {
    print("sending audio");
    if (audioFile != null) {
      // Endpoint URL
      var url =
          Uri.parse('http://arf9wb-ip-185-250-138-40.tunnelmole.net/upload/5');

      // Create multipart request
      var request = http.MultipartRequest('POST', url);

      // Add audio file to the request
      var audioFilePart = http.MultipartFile('audioFile',
          audioFile.readAsBytes().asStream(), audioFile.lengthSync(),
          filename: audioFile.path.split('/').last,
          contentType: MediaType('audio', 'mpeg'));
      request.files.add(audioFilePart);
      print("$request");

      // Send the request
      try {
        var response = await request.send();
        if (response.statusCode == 200) {
          print('Audio file uploaded successfully');
          // Handle success
        } else {
          print(
              'Failed to upload audio file. Status code: ${response.statusCode}');
          // Handle error
        }
      } catch (e) {
        print('Error uploading audio file: $e');
        // Handle error
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No audio file recorded."),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Microphone mode'),
      ),
      backgroundColor: Colors.grey.shade900,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
          ],
        ),
      ),
    );
  }
}
