import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

import '../models/menu_item.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/order_status.dart';

/// A menu item + quantity chosen while building a new order, before it is
/// persisted as an [OrderItem].
class OrderDraftItem {
  const OrderDraftItem({
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  final String menuItemId;
  final String name;
  final double price;
  final int quantity;

  double get subtotal => price * quantity;
}

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

  static final DocumentReference<Map<String, dynamic>> _orderCounter =
      FirebaseFirestore.instance.collection('meta').doc('counters');

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

  /// Creates a new order (with an auto-incrementing display number) along
  /// with all of its order_items, in a single transaction.
  static Future<String> placeOrder({
    required int tableNo,
    required List<OrderDraftItem> items,
  }) async {
    final orderDoc = orders.doc();
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final counterSnap = await tx.get(_orderCounter);
      final nextNumber =
          ((counterSnap.data()?['orders'] as num?)?.toInt() ?? 0) + 1;
      tx.set(_orderCounter, {'orders': nextNumber}, SetOptions(merge: true));

      final total = items.fold<double>(
        0,
        (runningTotal, item) => runningTotal + item.subtotal,
      );
      tx.set(
        orderDoc,
        Order(
          id: orderDoc.id,
          orderNumber: nextNumber,
          tableNo: tableNo,
          status: OrderStatus.pending,
          total: total,
          createdAt: null,
        ),
      );

      for (final item in items) {
        final itemDoc = orderItems.doc();
        tx.set(
          itemDoc,
          OrderItem(
            id: itemDoc.id,
            orderId: orderDoc.id,
            menuItemId: item.menuItemId,
            nameSnapshot: item.name,
            priceSnapshot: item.price,
            quantity: item.quantity,
          ),
        );
      }
    });
    return orderDoc.id;
  }

  /// Deletes an order and all of its order_items.
  static Future<void> cancelOrder(String orderId) async {
    final itemsSnapshot = await orderItems
        .where('order_id', isEqualTo: orderId)
        .get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in itemsSnapshot.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(orders.doc(orderId));
    await batch.commit();
  }
}
