import 'package:flutter/material.dart';

const categories = [
  {'key': 'animals', 'label': '동물', 'color': Colors.pinkAccent},
  // 채소 카테고리 제거됨
  {'key': 'fruits', 'label': '과일', 'color': Colors.orange},
  // 음식 카테고리 제거됨
  {'key': 'vehicles', 'label': '탈 것', 'color': Colors.blue},
  {'key': 'objects', 'label': '사물', 'color': Colors.purple},
  {'key': 'all', 'label': '모두 섞기', 'color': Colors.grey},
];

class CategorySelector extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const CategorySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8, // 간격 추가
      children:
          categories.map((cat) {
            final isSelected = selected.contains(cat['key']);
            return ChoiceChip(
              label: Text(
                cat['label'] as String,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              selected: isSelected,
              selectedColor: (cat['color'] as Color).withOpacity(0.7),
              backgroundColor: (cat['color'] as Color).withOpacity(0.3),
              onSelected: (_) {
                if (isSelected) {
                  onChanged(selected.where((c) => c != cat['key']).toList());
                } else {
                  onChanged([...selected, cat['key'] as String]);
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 2, // 그림자 추가
            );
          }).toList(),
    );
  }
}
