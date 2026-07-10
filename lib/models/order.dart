import 'package:cloud_firestore/cloud_firestore.dart';

import 'order_status.dart';

class Order {
  final String id;
  final int orderNumber;
  final int tableNo;
  final OrderStatus status;
  final double total;
  final DateTime? createdAt;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.tableNo,
    required this.status,
    required this.total,
    required this.createdAt,
  });

  /// Formatted as a 4-digit, zero-padded order number, e.g. "#0842".
  String get displayNumber => '#${orderNumber.toString().padLeft(4, '0')}';

  factory Order.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? _,
  ) {
    final data = doc.data() ?? {};
    return Order(
      id: doc.id,
      orderNumber: (data['order_number'] as num?)?.toInt() ?? 0,
      tableNo: (data['table_no'] as num?)?.toInt() ?? 0,
      status: OrderStatusX.fromLabel(data['status'] as String?),
      total: (data['total'] as num?)?.toDouble() ?? 0,
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'id': id,
    'order_number': orderNumber,
    'table_no': tableNo,
    'status': status.label,
    'total': total,
    'created_at': createdAt == null
        ? FieldValue.serverTimestamp()
        : Timestamp.fromDate(createdAt!),
  };
}
