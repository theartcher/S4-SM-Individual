import 'package:flutter/material.dart';
import 'package:microphone_mixer_flutter/pages/microphone.dart';
import 'package:microphone_mixer_flutter/pages/studio.dart';

const PRIMARY_COLOR = Color(0xFFfd0098);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final iconDefaultSize = 40.toDouble();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MicrophoneRoute()),
              );
            },
            child: Column(
              children: [
                Icon(
                  Icons.mic,
                  size: iconDefaultSize,
                  color: PRIMARY_COLOR,
                ),
                const Text(
                  'Microphone Mode',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StudioRoute()),
              );
            },
            child: Column(
              children: [
                Icon(
                  Icons.headphones,
                  size: iconDefaultSize,
                  color: PRIMARY_COLOR,
                ),
                const Text(
                  'Studio Mode',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
