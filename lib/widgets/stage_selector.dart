import 'package:flutter/material.dart';

class StageSelector extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const StageSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (idx) {
        final stage = idx + 1;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ElevatedButton(
            onPressed: () => onChanged(stage),
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              backgroundColor:
                  selected == stage ? Colors.pink : Colors.grey[300],
              padding: const EdgeInsets.all(24),
            ),
            child: Text(
              '$stage단계',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }),
    );
  }
}
