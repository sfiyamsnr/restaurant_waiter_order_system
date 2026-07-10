import 'package:flutter/material.dart';

import '../theme/app_constants.dart';

/// A numeric display box with stacked up/down chevron arrows on the right,
/// used for the table number input.
class NumberStepperField extends StatelessWidget {
  const NumberStepperField({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$value',
              style: const TextStyle(
                fontFamily: AppConstants.monoFontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Chevron(
                icon: Icons.keyboard_arrow_up_rounded,
                onTap: () => onChanged(value + 1),
              ),
              _Chevron(
                icon: Icons.keyboard_arrow_down_rounded,
                onTap: value > min ? () => onChanged(value - 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Icon(
        icon,
        size: 18,
        color: onTap == null ? const Color(0xFFB0B5BD) : const Color(0xFF6B7280),
      ),
    );
  }
}
