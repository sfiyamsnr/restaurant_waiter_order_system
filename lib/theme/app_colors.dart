import 'package:flutter/material.dart';

/// Design-system color tokens. Keep all hard-coded design colors here
/// rather than scattering hex literals through the screens.
class AppColors {
  AppColors._();

  static const background = Color(0xFFF0F2F5);
  static const primaryBlue = Color(0xFF2563EB);
  static const navy = Color(0xFF0F172A);

  static const statusPending = Color(0xFFF97316);
  static const statusPreparing = Color(0xFF3B82F6);
  static const statusServed = Color(0xFF22C55E);
  static const statusPaid = Color(0xFF9CA3AF);

  static const availableGreen = Color(0xFF22C55E);
  static const deleteRed = Color(0xFFEF4444);
  static const deleteRedBackground = Color(0xFFFEE2E2);
  static const editGrey = Color(0xFF6B7280);
  static const editGreyBackground = Color(0xFFE5E7EB);
}
