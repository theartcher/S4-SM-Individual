import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:microphone_mixer_flutter/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

export 'file_api.dart';

const FILE_API_URL = "https://yvvdyo-ip-185-250-138-40.tunnelmole.net";

void sendConvertedAudio(File? audioFile, BuildContext context) async {
  if (audioFile == null) {
    return snack("No audio file was recorded and was not sent.", context,
        snackOption: SnackOptions.error);
  }

  var url = Uri.parse('$FILE_API_URL/upload/1');

  var request = http.MultipartRequest('POST', url);

  var audioFilePart = http.MultipartFile(
      'audioFile', audioFile.readAsBytes().asStream(), audioFile.lengthSync(),
      filename: audioFile.path.split('/').last,
      contentType: MediaType('audio', 'mpeg'));
  request.files.add(audioFilePart);
  print("$request");

  try {
    var response = await request.send();

    if (response.statusCode == 200) {
      return snack("Audio uploaded successfully!", context,
          snackOption: SnackOptions.succes);
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
