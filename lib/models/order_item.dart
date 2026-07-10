import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String id;
  final String orderId;
  final String menuItemId;
  final String nameSnapshot;
  final double priceSnapshot;
  final int quantity;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.menuItemId,
    required this.nameSnapshot,
    required this.priceSnapshot,
    required this.quantity,
  });

  double get subtotal => priceSnapshot * quantity;

  factory OrderItem.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? _,
  ) {
    final data = doc.data() ?? {};
    return OrderItem(
      id: doc.id,
      orderId: data['order_id'] as String? ?? '',
      menuItemId: data['menu_item_id'] as String? ?? '',
      nameSnapshot: data['name_snapshot'] as String? ?? '',
      priceSnapshot: (data['price_snapshot'] as num?)?.toDouble() ?? 0,
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'id': id,
    'order_id': orderId,
    'menu_item_id': menuItemId,
    'name_snapshot': nameSnapshot,
    'price_snapshot': priceSnapshot,
    'quantity': quantity,
  };
}
