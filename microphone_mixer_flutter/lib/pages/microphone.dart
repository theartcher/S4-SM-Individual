import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:microphone_mixer_flutter/utils/_snackbar.dart';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http_parser/http_parser.dart';
import 'package:uuid/uuid.dart';

//! VARIABLE DECLARATIONS

const FILE_API_URL = "https://nps3rr-ip-185-250-138-40.tunnelmole.net";
var UNIQUE_ID = Uuid().v4();

class MicrophoneRoute extends StatefulWidget {
  const MicrophoneRoute({super.key});

  @override
  State<MicrophoneRoute> createState() => _MicrophoneRouteState();
}

class _MicrophoneRouteState extends State<MicrophoneRoute> {
  final FlutterSoundRecorder recorder = FlutterSoundRecorder();
  final double iconDefaultSize = 40.00;

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
    initWebsocket();
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    urlController.dispose();
    channel?.sink.close();
    super.dispose();
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
              toastOption: ToastOptions.warn);
      }
    });

    channel?.sink.add('Microphone mode - .');
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

  Future<void> startRecording(DateTime start) async {
    if (!isRecorderReady) {
      print("Is recorder ready? $isRecorderReady");
      return;
    }

    while (DateTime.now().isBefore(start)) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    var uuidGenerator = const Uuid();
    var uuid = uuidGenerator.v4();

    await recorder.startRecorder(toFile: 'audio');
  }

  Future<void> stopRecording(DateTime stop) async {
    if (!isRecording) {
      snack("Fakka je bent niet aan het opnemen G.", context);
      return;
    }

    if (!isRecorderReady) {
      snack("Is recorder ready? $isRecorderReady", context);
      return;
    }

    while (DateTime.now().isBefore(stop)) {
      await Future.delayed(const Duration(milliseconds: 50));
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
          Uri.parse('https://nps3rr-ip-185-250-138-40.tunnelmole.net/upload/5');

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
                labelStyle: const TextStyle(
                    color: Colors.white), // Set label text color
                hintStyle:
                    const TextStyle(color: Colors.white), // Set hint text color
              ),
              style: const TextStyle(color: Colors.purple), // Set text color
            ),
          ],
        ),
      ),
    );
  }
}
