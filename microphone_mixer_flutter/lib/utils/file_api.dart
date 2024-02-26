import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:microphone_mixer_flutter/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/public/util/flutter_sound_helper.dart';
import 'package:uuid/uuid.dart';

export 'file_api.dart';

const FILE_API_URL = "https://m4cx6t-ip-185-250-138-40.tunnelmole.net";
const GROUP_ID = "837238";

void sendConvertedAudio(File? audioFile, BuildContext context) async {
  if (audioFile == null) {
    return snack("No audio file was recorded and was not sent.", context,
        snackOption: SnackOptions.error);
  }

  String pcmFilePath = audioFile.path;
  var tempDir = await getTemporaryDirectory();
  var fileUuid = Uuid().v4();
  String wavFilePath = '${tempDir.path}/audio-${fileUuid}.wav';

  await flutterSoundHelper.pcmToWave(
    inputFile: pcmFilePath,
    outputFile: wavFilePath,
  );

  var url = Uri.parse('$FILE_API_URL/upload/$GROUP_ID');
  var request = http.MultipartRequest('POST', url);

  var audioFilePart = await http.MultipartFile.fromPath(
    'audioFile',
    wavFilePath,
    contentType: MediaType('audio', 'wav'),
  );

  request.files.add(audioFilePart);

  try {
    var response = await request.send();

    if (response.statusCode == 200) {
      return snack("Audio uploaded successfully!", context,
          snackOption: SnackOptions.success);
    }

    return snack(
        "Failed to upload audio file. Status code: ${response.statusCode}",
        context,
        snackOption: SnackOptions.error);
  } catch (e) {
    snack("Error uploading audio file - $e", context,
        snackOption: SnackOptions.error);
  }
}
