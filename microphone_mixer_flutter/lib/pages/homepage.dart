import 'package:flutter/material.dart';
import 'package:microphone_mixer_flutter/pages/microphone.dart';
import 'package:microphone_mixer_flutter/pages/studio.dart';

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
                ),
                const Text('Microphone Mode'),
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
                ),
                const Text('Studio Mode'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
