import 'package:flutter/material.dart';

/// A row of equal-width bordered option boxes, used for category selection.
/// Reused with different color themes (e.g. blue-outlined vs. filled dark).
class ChoiceTabs extends StatelessWidget {
  const ChoiceTabs({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.selectedBackground = const Color(0xFF2563EB),
    this.selectedForeground = Colors.white,
    this.selectedBorderColor,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;
  final Color selectedBackground;
  final Color selectedForeground;
  final Color? selectedBorderColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final option in options) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(option),
              child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: option == selected ? selectedBackground : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: option == selected
                        ? (selectedBorderColor ?? selectedBackground)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: option == selected
                        ? selectedForeground
                        : const Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
          if (option != options.last) const SizedBox(width: 8),
        ],
      ],
    );
  }
}
