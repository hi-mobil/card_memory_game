import 'package:flutter/material.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'card_widget.dart';
import 'confetti_button.dart';
import '../models/card_data.dart';
import '../models/image_data.dart';

class CardGame extends StatefulWidget {
  final int level;
  final List<CardData> cards;

  const CardGame({Key? key, required this.level, required this.cards})
      : super(key: key);

  @override
  State<CardGame> createState() => _CardGameState();
}

class _CardGameState extends State<CardGame> {
  bool _showConfetti = false;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _resetCardState() {
    // 카드 상태 초기화 로직
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[100],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Level ${widget.level}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh, size: 12),
                  onPressed: _resetCardState,
                ),
                IconButton(
                  icon: const Icon(Icons.celebration, size: 12),
                  onPressed: () {
                    setState(() {
                      _showConfetti = true;
                      _confettiController.play();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.pink[50]!, Colors.pink[100]!],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: widget.cards.length,
                    itemBuilder: (context, index) {
                      return CardWidget(
                        imagePath: widget.cards[index].imagePath,
                        label: widget.cards[index].label,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_showConfetti)
            Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: -pi / 2,
                maxBlastForce: 5,
                minBlastForce: 2,
                emissionFrequency: 0.05,
                numberOfParticles: 50,
                gravity: 0.1,
                shouldLoop: false,
                colors: const [
                  Colors.pink,
                  Colors.yellow,
                  Colors.blue,
                  Colors.green,
                  Colors.purple,
                ],
              ),
            ),
        ],
      ),
    );
  }
}
