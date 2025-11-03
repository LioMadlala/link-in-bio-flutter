import 'package:flutter/material.dart';

class ColorPalette {
  // Soft pastel colors that are easy on the eyes
  static const List<ColorOption> softColors = [
    ColorOption(
      name: 'Lavender',
      color: Color(0xFFE8D5FF),
      value: 'lavender',
    ),
    ColorOption(
      name: 'Mint',
      color: Color(0xFFD5F5E8),
      value: 'mint',
    ),
    ColorOption(
      name: 'Peach',
      color: Color(0xFFFFE8D5),
      value: 'peach',
    ),
    ColorOption(
      name: 'Sky Blue',
      color: Color(0xFFD5F0FF),
      value: 'skyblue',
    ),
    ColorOption(
      name: 'Rose',
      color: Color(0xFFFFE5F0),
      value: 'rose',
    ),
    ColorOption(
      name: 'Sage',
      color: Color(0xFFE5F5E8),
      value: 'sage',
    ),
    ColorOption(
      name: 'Butter',
      color: Color(0xFFFFF5D5),
      value: 'butter',
    ),
    ColorOption(
      name: 'Lilac',
      color: Color(0xFFF0E5FF),
      value: 'lilac',
    ),
    ColorOption(
      name: 'Powder Blue',
      color: Color(0xFFE5F0FF),
      value: 'powderblue',
    ),
    ColorOption(
      name: 'Blush',
      color: Color(0xFFFFF0F5),
      value: 'blush',
    ),
    ColorOption(
      name: 'Seafoam',
      color: Color(0xFFE5FFF5),
      value: 'seafoam',
    ),
    ColorOption(
      name: 'Cream',
      color: Color(0xFFFFFAF0),
      value: 'cream',
    ),
  ];

  static Color? getColorByValue(String? value) {
    if (value == null) return null;
    try {
      return softColors.firstWhere((c) => c.value == value).color;
    } catch (e) {
      return null;
    }
  }

  static ColorOption? getColorOptionByValue(String? value) {
    if (value == null) return null;
    try {
      return softColors.firstWhere((c) => c.value == value);
    } catch (e) {
      return null;
    }
  }

  static Color getDefaultColor() {
    return softColors[0].color; // Lavender
  }
}

class ColorOption {
  final String name;
  final Color color;
  final String value;

  const ColorOption({
    required this.name,
    required this.color,
    required this.value,
  });
}
