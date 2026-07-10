import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/material.dart';

import '../models/order.dart';
import '../models/order_item.dart';
import '../models/order_status.dart';
import '../services/firestore_refs.dart';
import '../widgets/add_order_item_dialog.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Future<void> _addItem() async {
    final selection = await showAddOrderItemDialog(context);
    if (selection == null) return;
    final doc = FirestoreRefs.orderItems.doc();
    await doc.set(
      OrderItem(
        id: doc.id,
        orderId: widget.orderId,
        menuItemId: selection.menuItem.id,
        nameSnapshot: selection.menuItem.name,
        priceSnapshot: selection.menuItem.price,
        quantity: selection.quantity,
      ),
    );
    await FirestoreRefs.recalculateOrderTotal(widget.orderId);
  }

  Future<void> _removeItem(OrderItem item) async {
    await FirestoreRefs.orderItems.doc(item.id).delete();
    await FirestoreRefs.recalculateOrderTotal(widget.orderId);
  }

  Future<void> _changeStatus(OrderStatus status) async {
    await FirestoreRefs.orders.doc(widget.orderId).update({
      'status': status.label,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: StreamBuilder<DocumentSnapshot<Order>>(
        stream: FirestoreRefs.orders.doc(widget.orderId).snapshots(),
        builder: (context, orderSnapshot) {
          if (orderSnapshot.hasError) {
            return Center(child: Text('Error: ${orderSnapshot.error}'));
          }
          if (!orderSnapshot.hasData || !orderSnapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }
          final order = orderSnapshot.data!.data()!;

          return Column(
            children: [
              _OrderHeader(order: order, onChangeStatus: _changeStatus),
              const Divider(height: 1),
              Expanded(
                child: StreamBuilder<QuerySnapshot<OrderItem>>(
                  stream: FirestoreRefs.orderItems
                      .where('order_id', isEqualTo: widget.orderId)
                      .snapshots(),
                  builder: (context, itemsSnapshot) {
                    if (itemsSnapshot.hasError) {
                      return Center(child: Text('Error: ${itemsSnapshot.error}'));
                    }
                    if (!itemsSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final items = itemsSnapshot.data!.docs
                        .map((d) => d.data())
                        .toList();

                    if (items.isEmpty) {
                      return const Center(
                        child: Text('No items yet. Tap "Add Item" to begin.'),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(item.nameSnapshot),
                            subtitle: Text(
                              '${item.quantity} × \$${item.priceSnapshot.toStringAsFixed(2)}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '\$${item.subtotal.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded),
                                  tooltip: 'Remove',
                                  onPressed: () => _removeItem(item),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addItem,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Item'),
      ),
    );
  }
}

class _OrderHeader extends StatelessWidget {
  const _OrderHeader({required this.order, required this.onChangeStatus});

  final Order order;
  final ValueChanged<OrderStatus> onChangeStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      color: theme.colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Table ${order.tableNo}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${order.total.toStringAsFixed(2)}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: OrderStatus.values.map((status) {
              final selected = status == order.status;
              return ChoiceChip(
                avatar: Icon(status.icon, size: 16, color: selected ? Colors.white : status.color),
                label: Text(status.label),
                selected: selected,
                selectedColor: status.color,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : status.color,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (_) => onChangeStatus(status),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
