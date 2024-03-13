import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:pew_pew_nfc/widgets/scanner/start_game.dart';
import '../utils/snackbar.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key});

  @override
  State<StatefulWidget> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  List<NfcTag> tags = [];

  @override
  void initState() {
    super.initState();
    _checkNfcPermission();
    initReader();
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }

  void initReader() {
    NfcManager.instance.startSession(
      invalidateAfterFirstRead: false,
      onDiscovered: (NfcTag tag) async {
        _readTag(tag);
      },
    );
  }

  Future<void> _checkNfcPermission() async {
    bool isNfcPermissionEnabled = await NfcManager.instance.isAvailable();
    if (!isNfcPermissionEnabled) {
      snack("No NFC permissions.", context,
          snackOption: SnackOptions.error, milliSecondsToShow: 2000);
    }
  }

  void _removeLast() {
    if (tags.isEmpty) {
      snack("There are no saved tags.", context,
          snackOption: SnackOptions.warn, milliSecondsToShow: 500);
      return;
    }

    setState(() {
      final lastTag = tags.last;
      tags.removeLast();

      if (tags.isEmpty || lastTag != tags.last) {
        snack("Removed last.", context,
            snackOption: SnackOptions.success, milliSecondsToShow: 500);
      } else {
        snack("Failed to remove last.", context,
            snackOption: SnackOptions.error, milliSecondsToShow: 2000);
      }
    });
  }

  void _removeAll() {
    if (tags.isEmpty) {
      return snack("There are no saved tags.", context,
          snackOption: SnackOptions.warn, milliSecondsToShow: 500);
    }

    setState(() {
      tags = [];
    });

    if (tags.isEmpty) {
      return snack("Removed all saved NFC tags.", context,
          snackOption: SnackOptions.success, milliSecondsToShow: 500);
    }
  }

  void _readTag(NfcTag tag) async {
    List<int>? tagIdentifier = tag.data['nfca']?['identifier'];

    if (tagIdentifier == null) {
      snack("An error occurred reading the tag. Perhaps it's incompatible",
          context,
          snackOption: SnackOptions.error, milliSecondsToShow: 1000);
      return;
    }

    bool isTagNew = !tags.any((element) =>
        element.data['nfca']?['identifier'].toString() ==
        tagIdentifier.toString());

    if (isTagNew) {
      setState(() {
        tags.add(tag);
      });
      snack('Added NFC tag.', context,
          snackOption: SnackOptions.success, milliSecondsToShow: 500);
    } else {
      snack('Tag is already in list.', context,
          snackOption: SnackOptions.warn, milliSecondsToShow: 1000);
    }

    if (tags.length >= 3) {
      snack(
          "You've got enough tags to play, continue or add more tags.", context,
          snackOption: SnackOptions.success, milliSecondsToShow: 1500);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pew pew simulator')),
      body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              tutorialText,
              divider,
              Text(
                  tags.length < 3
                      ? "Scan ${3 - tags.length} more NFC tags!"
                      : "Minimal required amount of tags scanned.",
                  style: const TextStyle(
                      fontSize: 20, color: Color.fromARGB(255, 33, 41, 132))),
              divider,
              StartGame(tags: tags),
              divider,
              ElevatedButton(
                onPressed: tags.isEmpty
                    ? null
                    : () {
                        _removeLast();
                      },
                child: const Text('Remove last scanned',
                    style: TextStyle(color: Colors.lightBlue)),
              ),
              ElevatedButton(
                onPressed: tags.isEmpty
                    ? null
                    : () {
                        _removeAll();
                      },
                child: const Text('Remove ALL scanned',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          )),
    );
  }
}

const divider = SizedBox(
  width: 100,
  height: 25,
);

const tutorialText = Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text("How to play", style: TextStyle(fontSize: 20)),
    Text("1. Scan at least 3 NFC tags.", style: TextStyle(fontSize: 15)),
    Text("2. Press game!", style: TextStyle(fontSize: 15)),
    Text("3. Shoot the duck, don't miss.", style: TextStyle(fontSize: 15)),
    Text("4. Kill the duck before running out of time or bullets.",
        style: TextStyle(fontSize: 15)),
  ],
);
