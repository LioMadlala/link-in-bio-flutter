import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';

import '../constants/social_icons.dart';
import '../utils/icon_helper.dart';

class SocialIconPicker extends StatefulWidget {
  final String? selectedIcon;
  final Function(String?) onIconSelected;

  const SocialIconPicker({
    super.key,
    required this.selectedIcon,
    required this.onIconSelected,
  });

  @override
  State<SocialIconPicker> createState() => _SocialIconPickerState();
}

class _SocialIconPickerState extends State<SocialIconPicker> {
  final TextEditingController _customIconController = TextEditingController();
  bool _showCustomInput = false;

  @override
  void dispose() {
    _customIconController.dispose();
    super.dispose();
  }

  void _handleCustomIcon() {
    final iconName = _customIconController.text.trim();
    if (iconName.isNotEmpty) {
      widget.onIconSelected(iconName);
      setState(() {
        _showCustomInput = false;
        _customIconController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Popular icons grid
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ...SocialIcons.popularIcons.entries.map((entry) {
              final iconName = SocialIcons.popular[entry.key] ?? '';
              final isSelected = widget.selectedIcon == iconName;
              return GestureDetector(
                onTap: () => widget.onIconSelected(iconName),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.grey.shade100
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Colors.blue.shade400
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Builder(
                      builder: (context) {
                        try {
                          final iconData = (entry.value as Function)();
                          return Iconify(iconData, size: 28);
                        } catch (e) {
                          // Fallback to string-based iconify
                          return Iconify(iconName, size: 28);
                        }
                      },
                    ),
                  ),
                ),
              );
            }),
            // Custom icon button
            GestureDetector(
              onTap: () {
                setState(() {
                  _showCustomInput = !_showCustomInput;
                  if (!_showCustomInput) {
                    _customIconController.clear();
                  }
                });
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _showCustomInput
                      ? Colors.blue.shade50
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _showCustomInput
                        ? Colors.blue.shade400
                        : Colors.grey.shade300,
                    width: _showCustomInput ? 2 : 1,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.add, size: 28, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
        // Custom icon input
        if (_showCustomInput) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customIconController,
                  decoration: const InputDecoration(
                    labelText: 'Paste iconify icon name',
                    hintText: 'e.g., mdi:github, logos:instagram-icon',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _handleCustomIcon,
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Visit iconify.design to find icons and paste the icon name here',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
        // Show selected icon preview
        if (widget.selectedIcon != null && !_showCustomInput) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Builder(
                  builder: (context) {
                    return IconHelper.buildIconWidget(
                      widget.selectedIcon,
                      size: 32,
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Selected: ${widget.selectedIcon}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => widget.onIconSelected(null),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
