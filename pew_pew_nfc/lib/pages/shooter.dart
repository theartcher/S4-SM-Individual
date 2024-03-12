import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:vibration/vibration.dart';
import '../utils/snackbar.dart';

const initialBullets = 20;

class Shooter extends StatefulWidget {
  final List<NfcTag> ammo;
  const Shooter({super.key, required this.ammo});

  @override
  State<StatefulWidget> createState() => _ShooterState();
}

class _ShooterState extends State<Shooter> {
  int ammoIndex = 0;
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
    List<int>? tagIdentifier = tag.data['nfca']?['identifier'];

    if (tagIdentifier == null) {
      return snack(
          "An error occurred reading the tag. Perhaps it's incompatible",
          context,
          snackOption: SnackOptions.error,
          milliSecondsToShow: 1000);
    }

    var maxAmmoIndex = widget.ammo.length - 1;

    if (ammoIndex > maxAmmoIndex) {
      return snack("You've used all the magazines", context,
          snackOption: SnackOptions.warn, milliSecondsToShow: 500);
    }

    bool isCorrectTagAtIndex = widget.ammo
            .elementAt(ammoIndex)
            .data['nfca']?["identifier"]
            .toString() ==
        tagIdentifier.toString();

    bool isTagInList = !widget.ammo.any((element) =>
        element.data['ndef']?['identifier'].toString() ==
        tagIdentifier.toString());

    if (!isTagInList) {
      return snack("This magazine won't fit.", context,
          snackOption: SnackOptions.error, milliSecondsToShow: 500);
    }

    if (isCorrectTagAtIndex) {
      setState(() {
        bullets += 20;
        ammoIndex += 1;
      });
      return snack('Magazine found! +20 bullets!', context,
          snackOption: SnackOptions.success, milliSecondsToShow: 500);
    } else {
      return snack("Ugh, I can't use this magazine right now!", context,
          snackOption: SnackOptions.warn, milliSecondsToShow: 500);
    }
  }

  void _resetGame() async {
    setState(() {
      Navigator.pop(context);
    });
  }

  void _shoot() {
    if (bullets >= 5) {
      setState(() {
        bullets -= 5;
      });

      Vibration.vibrate(duration: 250);
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
              child: const Text('QUIT', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
