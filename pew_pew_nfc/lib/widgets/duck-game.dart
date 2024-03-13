import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'package:pew_pew_nfc/utils/snackbar.dart';

class DuckGame extends StatefulWidget {
  final void Function() onHit;
  final void Function() onMiss;

  const DuckGame({Key? key, required this.onHit, required this.onMiss})
      : super(key: key);

  @override
  State<DuckGame> createState() => _DuckGameState();
}

class _DuckGameState extends State<DuckGame>
    with SingleTickerProviderStateMixin {
  late final GifController _controller;
  late Timer _timer;
  late Offset _offset;
  late double _maxWidth;
  late double _maxHeight;

  @override
  void initState() {
    _controller = GifController(vsync: this);
    _offset = Offset.zero;
    _startRandomMovement();
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startRandomMovement() {
    final random = Random();
    var randomTime = 750;

    _timer = Timer.periodic(Duration(milliseconds: randomTime), (timer) {
      setState(() {
        randomTime = _getRandomTime(250, 1000);
        _offset = Offset(
          random.nextDouble() * (_maxWidth - 300),
          random.nextDouble() * (_maxHeight - 300),
        );
      });
    });
  }

  int _getRandomTime(int msMin, int msMax) {
    final randomDelay = Random().nextInt(msMax) + msMin;
    print("Random delay: $randomDelay");
    return randomDelay;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        _maxWidth = constraints.maxWidth;
        _maxHeight = constraints.maxHeight;
        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Positioned(
            left: 39,
            top: 82,
            child: GestureDetector(
              onTap: () {
                widget.onMiss();
              },
              child: Container(
                alignment: Alignment.center,
                color: Color.fromRGBO(35, 129, 188, 1),
                child: Transform.translate(
                  offset: _offset,
                  child: GestureDetector(
                      onTap: () {
                        widget.onHit();
                      },
                      child: Gif(
                        width: 150,
                        height: 150,
                        image: const AssetImage("assets/images/damn-duck.gif"),
                        controller: _controller,
                        autostart: Autostart.loop,
                        placeholder: (context) => const Text('Loading game...'),
                        onFetchCompleted: () {
                          _controller.reset();
                          _controller.forward();
                        },
                      )),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
