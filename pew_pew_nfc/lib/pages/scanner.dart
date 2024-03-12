import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:pew_pew_nfc/pages/shooter.dart';
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                tags.length < 3
                    ? "Scan ${3 - tags.length} more NFC tags!"
                    : "Required amount of tags scanned.",
                style: const TextStyle(
                    fontSize: 20, color: Color.fromARGB(255, 33, 41, 132))),
            const Text(
                "Please scan your tags in the order that you want to play with them.",
                style: TextStyle(fontSize: 20)),
            ElevatedButton(
              onPressed: tags.length < 3
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Shooter(
                            ammo: tags,
                          ),
                        ),
                      );
                    },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.disabled)) {
                    return Colors.red;
                  }
                  return Colors.green;
                }),
              ),
              child: const Text(
                'Game!',
                style: TextStyle(color: Colors.white),
              ),
            ),
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
        ),
      ),
    );
  }
}
