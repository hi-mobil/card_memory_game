import 'package:flutter/material.dart';
import 'widgets/category_selector.dart';
import 'widgets/stage_selector.dart';
import 'widgets/card_game.dart';
import 'widgets/chalkboard.dart';
import 'models/card_data.dart';
import 'models/image_data.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' show pi;

void main() {
  runApp(const CardMemoryGameApp());
}

class CardMemoryGameApp extends StatelessWidget {
  const CardMemoryGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '그림카드 기억력 게임',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Jua'),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> selectedCategories = ['animals'];
  int selectedStage = 1;
  bool showChalkboard = false;
  final confettiController =
      ConfettiController(duration: const Duration(seconds: 1));
  List<bool> cardFlippedStates = [];
  bool _isFlippingAll = false;
  List<Map<String, String>> _currentCards = [];

  @override
  void initState() {
    super.initState();
    _resetCardStates();
  }

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }

  void _resetCardStates() {
    final cardCount = [2, 3, 4, 5][selectedStage - 1];
    cardFlippedStates = List.generate(cardCount, (_) => false);
    _currentCards = getRandomCards(selectedCategories, cardCount);
  }

  void _flipAllCards() {
    setState(() {
      _isFlippingAll = true;
      cardFlippedStates = cardFlippedStates.map((state) => !state).toList();
    });
  }

  void _onCardFlip(int index) {
    setState(() {
      cardFlippedStates[index] = !cardFlippedStates[index];
    });
  }

  List<Map<String, String>> getRandomCards(List<String> cats, int count) {
    List<Map<String, String>> pool = [];
    if (cats.contains('all')) {
      ImageData.imageMap.values.forEach((list) => pool.addAll(list));
    } else {
      for (final cat in cats) {
        if (ImageData.imageMap[cat] != null) {
          pool.addAll(ImageData.imageMap[cat]!);
        }
      }
    }

    if (pool.length < count) {
      print(
        '경고: 선택된 카테고리에 이미지가 부족합니다. 필요한 카드 수: $count, 사용 가능한 이미지 수: ${pool.length}',
      );
      count = pool.length;
    }

    pool.shuffle();
    return pool.take(count).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (showChalkboard) {
      return Chalkboard(onBack: () => setState(() => showChalkboard = false));
    }
    return Scaffold(
      backgroundColor: const Color(0xFFe0e7ff),
      appBar: AppBar(
        backgroundColor: Colors.pink[100],
        elevation: 0,
        title: const Text('그림카드 기억력 게임',
            style: TextStyle(
              color: Colors.pink,
              fontSize: 20,
            )),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.flip, color: Colors.pink, size: 28),
            onPressed: _flipAllCards,
            tooltip: '모든 카드 뒤집기',
          ),
          IconButton(
            icon: const Icon(Icons.celebration, color: Colors.pink, size: 28),
            onPressed: () => confettiController.play(),
            tooltip: '폭죽',
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: Colors.pink[50],
                child: Column(
                  children: [
                    CategorySelector(
                      selected: selectedCategories,
                      onChanged: (cats) {
                        setState(() {
                          selectedCategories = cats;
                          _resetCardStates();
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    StageSelector(
                      selected: selectedStage,
                      onChanged: (stage) {
                        setState(() {
                          selectedStage = stage;
                          _resetCardStates();
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () =>
                              setState(() => showChalkboard = true),
                          child: const Text('칠판',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              )),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow[700],
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _currentCards.length,
                    itemBuilder: (context, index) {
                      final card = _currentCards[index];
                      return GestureDetector(
                        onTap: () => _onCardFlip(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(cardFlippedStates[index] ? pi : 0),
                            child: CardGameCard(
                              imagePath: card['src']!,
                              label: card['label']!,
                              isFlipped: cardFlippedStates[index],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CardGameCard extends StatelessWidget {
  final String imagePath;
  final String label;
  final bool isFlipped;

  const CardGameCard({
    required this.imagePath,
    required this.label,
    this.isFlipped = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Stack(
        children: [
          // 앞면
          AnimatedOpacity(
            opacity: isFlipped ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.help_outline,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 뒷면
          AnimatedOpacity(
            opacity: isFlipped ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(imagePath, fit: BoxFit.contain),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
