import 'package:flutter/material.dart';
import '../utils/color_palette.dart';

class ColorPickerWidget extends StatelessWidget {
  final String? selectedValue;
  final Function(String?) onColorSelected;

  const ColorPickerWidget({
    super.key,
    required this.selectedValue,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: ColorPalette.softColors.map((colorOption) {
        final isSelected = colorOption.value == selectedValue;
        return GestureDetector(
          onTap: () => onColorSelected(colorOption.value),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorOption.color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.grey.shade700 : Colors.grey.shade300,
                width: isSelected ? 3 : 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: colorOption.color.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    color: Colors.black54,
                    size: 24,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}
