import 'package:cloud_firestore/cloud_firestore.dart';

import 'order_status.dart';

class Order {
  final String id;
  final int tableNo;
  final OrderStatus status;
  final double total;
  final DateTime? createdAt;

  const Order({
    required this.id,
    required this.tableNo,
    required this.status,
    required this.total,
    required this.createdAt,
  });

  factory Order.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? _,
  ) {
    final data = doc.data() ?? {};
    return Order(
      id: doc.id,
      tableNo: (data['table_no'] as num?)?.toInt() ?? 0,
      status: OrderStatusX.fromLabel(data['status'] as String?),
      total: (data['total'] as num?)?.toDouble() ?? 0,
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'id': id,
    'table_no': tableNo,
    'status': status.label,
    'total': total,
    'created_at': createdAt == null
        ? FieldValue.serverTimestamp()
        : Timestamp.fromDate(createdAt!),
  };
}
