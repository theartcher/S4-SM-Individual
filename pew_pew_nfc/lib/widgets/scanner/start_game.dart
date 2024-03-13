import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:pew_pew_nfc/pages/shooter.dart';

class StartGame extends StatelessWidget {
  late final List<NfcTag> tags;

  StartGame({super.key, required this.tags});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
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
        backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.red;
          }
          return Colors.green;
        }),
      ),
      child: const Text(
        'Game!',
        style: TextStyle(fontSize: 30, color: Colors.white),
      ),
    );
  }
}
