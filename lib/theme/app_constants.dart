/// Cosmetic branding text. Not backed by Firestore — there's no
/// restaurant/waiter identity field in the data model, so these are
/// hardcoded display values only.
class AppConstants {
  AppConstants._();

  static const restaurantName = 'Kopitiam Kita';
  static const waiterInitials = 'W1';

  static const monoFontFamily = 'monospace';

  static String money(double value) => 'RM ${value.toStringAsFixed(2)}';
}
