import 'package:flutter/material.dart';

import '../models/order_status.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(status.icon, size: 16, color: status.color),
      label: Text(
        status.label,
        style: TextStyle(
          color: status.color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
      backgroundColor: status.color.withValues(alpha: 0.12),
      side: BorderSide(color: status.color.withValues(alpha: 0.3)),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
