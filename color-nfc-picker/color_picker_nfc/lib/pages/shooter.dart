import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import '../utils/snackbar.dart';

const initialBullets = 20;

class Shooter extends StatefulWidget {
  const Shooter({super.key});

  @override
  State<StatefulWidget> createState() => _ShooterState();
}

class _ShooterState extends State<Shooter> {
  List<NfcTag> usedTags = [];
  int bullets = initialBullets;

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
      print("NFC not available");
    }
  }

  void _readTag(NfcTag tag) async {
    List<int>? tagIdentifier = tag.data['ndef']['identifier'];

    if (tagIdentifier == null) {
      snack("An error occurred reading the tag. Perhaps it's incompatible",
          context,
          snackOption: SnackOptions.error, milliSecondsToShow: 1000);
      return;
    }

    bool isTagNew = !usedTags.any((element) =>
        element.data['ndef']['identifier'].toString() ==
        tagIdentifier.toString());

    if (isTagNew) {
      setState(() {
        usedTags.add(tag);
        bullets += 20;
      });
      snack('Magazine found! +20 bullets!', context,
          snackOption: SnackOptions.success, milliSecondsToShow: 500);
    } else {
      snack("Ugh, this magazine has no more bullets left!", context,
          snackOption: SnackOptions.error, milliSecondsToShow: 500);
    }
  }

  void _resetGame() async {
    setState(() {
      bullets = initialBullets;
    });
    setState(() {
      usedTags = [];
    });
  }

  void _shoot() {
    if (bullets >= 5) {
      setState(() {
        bullets -= 5;
      });
      snack('PEW! -5 bullets!', context,
          snackOption: SnackOptions.success, milliSecondsToShow: 200);
    }

    if (bullets <= 0) {
      snack('Out of bullets!', context, snackOption: SnackOptions.error);
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
            Text(bullets <= 0 ? "No bullets left" : "$bullets bullets left",
                style: const TextStyle(fontSize: 30)),
            ElevatedButton(
              onPressed: bullets >= 5 ? _shoot : null,
              child: const Text('SHOOT', style: TextStyle(color: Colors.green)),
            ),
            ElevatedButton(
              onPressed: _resetGame,
              child: const Text('RESET', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
