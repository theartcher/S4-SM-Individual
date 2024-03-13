import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:pew_pew_nfc/widgets/duck-game.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:vibration/vibration.dart';
import '../utils/snackbar.dart';

const initialBullets = 5;

class Shooter extends StatefulWidget {
  final List<NfcTag> ammo;
  const Shooter({super.key, required this.ammo});

  @override
  State<StatefulWidget> createState() => _ShooterState();
}

class _ShooterState extends State<Shooter> {
  bool gameOver = false;
  int ammoIndex = 0;
  int health = 10;
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

  void _gameOver() {
    setState(() {
      gameOver = true;
    });
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
        bullets += 5;
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

  bool _shoot() {
    if (bullets >= 1) {
      setState(() {
        bullets -= 1;
      });
      return true;
    }

    if (bullets <= 0) {
      snack('Out of bullets!', context, snackOption: SnackOptions.error);
      return false;
    }
    return false;
  }

  void _onHit() {
    if (!_shoot()) return;

    setState(() {
      health -= 1;
    });

    Vibration.vibrate(duration: 250);
    snack('HIT', context,
        snackOption: SnackOptions.success, milliSecondsToShow: 200);
  }

  void _onMiss() {
    if (!_shoot()) return;
    snack("MISS", context,
        snackOption: SnackOptions.warn, milliSecondsToShow: 250);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pew pew simulator')),
      body: Center(
        child: health > 0 && bullets <= 0 && ammoIndex >= widget.ammo.length ||
                gameOver
            ? const Text("WOMP WOMP YOU SUCK!",
                style: TextStyle(fontSize: 50, color: Colors.red))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Countdown(
                    seconds: 30,
                    build: (BuildContext context, double time) =>
                        Text(time.toString()),
                    interval: Duration(milliseconds: 100),
                    onFinished: () {
                      _gameOver();
                    },
                  ),
                  Text(
                      bullets <= 0
                          ? "No bullets left"
                          : "$bullets bullets left",
                      style: const TextStyle(fontSize: 30)),
                  Text("$health HP",
                      style: const TextStyle(fontSize: 25, color: Colors.red)),
                  Expanded(
                    child: Container(
                      child: health > 0
                          ? DuckGame(
                              onHit: _onHit,
                              onMiss: _onMiss,
                            )
                          : const Text("You win!",
                              style:
                                  TextStyle(fontSize: 50, color: Colors.green)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _resetGame,
                    child:
                        const Text('QUIT', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
      ),
    );
  }
}
