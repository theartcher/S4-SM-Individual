import 'dart:io';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:microphone_mixer_flutter/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

export 'file_api.dart';

const FILE_API_URL = "https://brown-bats-yell.loca.lt";
const GROUP_ID = "837238";

void sendConvertedAudio(File? audioFile, BuildContext context) async {
  if (audioFile == null) {
    return snack("No audio file was recorded and was not sent.", context,
        snackOption: SnackOptions.error);
  }

  var url = Uri.parse('$FILE_API_URL/upload/$GROUP_ID');
  var request = http.MultipartRequest('POST', url);

  var audioFilePart = http.MultipartFile(
      'audioFile', audioFile.readAsBytes().asStream(), audioFile.lengthSync(),
      filename: audioFile.path.split('/').last,
      contentType: MediaType('audio', 'm4a'));
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
  } catch (error) {
    snack("Error uploading audio file - $error", context,
        snackOption: SnackOptions.error);
  }
}

Future<String> collectMergedAudio(BuildContext context, String groupID) async {
  snack("Fetching audio...", context, snackOption: SnackOptions.info);

  try {
    var apiUrl = Uri.parse('$FILE_API_URL/files/$groupID');
    Response response = await get(apiUrl);

    if (response.statusCode == 200) {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      File file = File('${appDocDir.path}/audio.m4a');

      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    }

    snack("Failed to fetch audio", context, snackOption: SnackOptions.error);
    return '';
  } catch (error) {
    snack("Error fetching audio - $error", context,
        snackOption: SnackOptions.error);
    return 'null';
  }
}
