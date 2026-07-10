import 'package:flutter/material.dart';

enum OrderStatus { pending, preparing, served, paid }

extension OrderStatusX on OrderStatus {
  String get label => switch (this) {
    OrderStatus.pending => 'Pending',
    OrderStatus.preparing => 'Preparing',
    OrderStatus.served => 'Served',
    OrderStatus.paid => 'Paid',
  };

  IconData get icon => switch (this) {
    OrderStatus.pending => Icons.hourglass_top_rounded,
    OrderStatus.preparing => Icons.soup_kitchen_rounded,
    OrderStatus.served => Icons.room_service_rounded,
    OrderStatus.paid => Icons.check_circle_rounded,
  };

  Color get color => switch (this) {
    OrderStatus.pending => const Color(0xFFB98900),
    OrderStatus.preparing => const Color(0xFF2E6FDB),
    OrderStatus.served => const Color(0xFF2E9E5B),
    OrderStatus.paid => const Color(0xFF7C4FD0),
  };

  static OrderStatus fromLabel(String? value) {
    return OrderStatus.values.firstWhere(
      (s) => s.label == value,
      orElse: () => OrderStatus.pending,
    );
  }
}
