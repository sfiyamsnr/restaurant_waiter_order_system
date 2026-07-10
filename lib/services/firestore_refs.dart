import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

import '../models/menu_item.dart';
import '../models/order.dart';
import '../models/order_item.dart';

class FirestoreRefs {
  FirestoreRefs._();

  static final CollectionReference<MenuItem> menuItems = FirebaseFirestore
      .instance
      .collection('menu_items')
      .withConverter<MenuItem>(
        fromFirestore: MenuItem.fromFirestore,
        toFirestore: (item, _) => item.toFirestore(),
      );

  static final CollectionReference<Order> orders = FirebaseFirestore.instance
      .collection('orders')
      .withConverter<Order>(
        fromFirestore: Order.fromFirestore,
        toFirestore: (order, _) => order.toFirestore(),
      );

  static final CollectionReference<OrderItem> orderItems = FirebaseFirestore
      .instance
      .collection('order_items')
      .withConverter<OrderItem>(
        fromFirestore: OrderItem.fromFirestore,
        toFirestore: (item, _) => item.toFirestore(),
      );

  /// Recomputes an order's total from its order_items and writes it back.
  static Future<void> recalculateOrderTotal(String orderId) async {
    final snapshot = await orderItems
        .where('order_id', isEqualTo: orderId)
        .get();
    final total = snapshot.docs.fold<double>(
      0,
      (runningTotal, doc) => runningTotal + doc.data().subtotal,
    );
    await orders.doc(orderId).update({'total': total});
  }
}
