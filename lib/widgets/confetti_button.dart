import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class ConfettiButton extends StatefulWidget {
  const ConfettiButton({super.key});

  @override
  State<ConfettiButton> createState() => _ConfettiButtonState();
}

class _ConfettiButtonState extends State<ConfettiButton> {
  final _controller = ConfettiController(duration: const Duration(seconds: 2));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _fireConfetti() {
    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ConfettiWidget(
          confettiController: _controller,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          numberOfParticles: 40,
          maxBlastForce: 20,
          minBlastForce: 8,
          emissionFrequency: 0.05,
          gravity: 0.2,
        ),
        ElevatedButton(
          onPressed: _fireConfetti,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink[400],
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: const Text(
            '폭죽!',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
