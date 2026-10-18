import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class ConfettiEffect extends StatefulWidget {
  final ConfettiController controller;
  final bool isStrong; // true for level complete, false for correct answer

  const ConfettiEffect({super.key, required this.controller, this.isStrong = false});

  @override
  State<ConfettiEffect> createState() => _ConfettiEffectState();
}

class _ConfettiEffectState extends State<ConfettiEffect> {
  @override
  Widget build(BuildContext context) {
    return ConfettiWidget(
      confettiController: widget.controller,
      blastDirectionality: BlastDirectionality.explosive, // radial
      shouldLoop: false,
      colors: const [
        Colors.green,
        Colors.blue,
        Colors.pink,
        Colors.orange,
        Colors.purple
      ], // manually specify the colors to be used
      createParticlePath: drawStar, // define a custom shape/path.
      numberOfParticles: widget.isStrong ? 50 : 20,
      gravity: widget.isStrong ? 0.2 : 0.1,
      emissionFrequency: 0.05,
    );
  }

  /// A custom Path to paint circles/stars.
  Path drawStar(Size size) {
    return Path()..addOval(Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2));
  }
}
