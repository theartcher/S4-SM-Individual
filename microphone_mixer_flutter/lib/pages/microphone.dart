import 'package:flutter/material.dart';

class MicrophoneRoute extends StatefulWidget {
  const MicrophoneRoute({super.key});

  @override
  State<MicrophoneRoute> createState() => _MicrophoneRouteState();
}

class _MicrophoneRouteState extends State<MicrophoneRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Microphone mode'),
      ),
      backgroundColor: Colors.grey.shade900,
      body: const Center(
        child: Placeholder(),
      ),
    );
  }
}
