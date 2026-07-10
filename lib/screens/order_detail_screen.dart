import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/material.dart';

import '../models/order.dart';
import '../models/order_item.dart';
import '../models/order_status.dart';
import '../services/firestore_refs.dart';
import '../theme/app_colors.dart';
import '../theme/app_constants.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _busy = false;

  Future<void> _advanceStatus(OrderStatus next) async {
    setState(() => _busy = true);
    await FirestoreRefs.orders.doc(widget.orderId).update({
      'status': next.label,
    });
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _cancelOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Order?'),
        content: const Text('This will permanently remove the order.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep Order'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              foregroundColor: AppColors.deleteRed,
            ),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _busy = true);
    await FirestoreRefs.cancelOrder(widget.orderId);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: StreamBuilder<DocumentSnapshot<Order>>(
        stream: FirestoreRefs.orders.doc(widget.orderId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          final order = snapshot.data!.data()!;

          return SafeArea(
            child: Column(
              children: [
                _TopBar(order: order, onBack: () => Navigator.of(context).pop()),
                Container(height: 3, color: AppColors.primaryBlue),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _ReceiptCard(order: order),
                  ),
                ),
                _BottomActions(
                  status: order.status,
                  busy: _busy,
                  onAdvance: () => _advanceStatus(_nextStatus(order.status)),
                  onCancel: _cancelOrder,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  OrderStatus _nextStatus(OrderStatus current) {
    switch (current) {
      case OrderStatus.pending:
        return OrderStatus.preparing;
      case OrderStatus.preparing:
        return OrderStatus.served;
      case OrderStatus.served:
        return OrderStatus.paid;
      case OrderStatus.paid:
        return OrderStatus.paid;
    }
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.order, required this.onBack});

  final Order order;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Material(
                color: const Color(0xFF1E293B),
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onBack,
                  child: const SizedBox(
                    width: 36,
                    height: 36,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: order.status.color,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                order.status.label.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                order.displayNumber,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontFamily: AppConstants.monoFontFamily,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            AppConstants.restaurantName.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'TABLE ${order.tableNo} · ${_formatTime(order.createdAt)}',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          const _DashedDivider(),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot<OrderItem>>(
            stream: FirestoreRefs.orderItems
                .where('order_id', isEqualTo: order.id)
                .snapshots(),
            builder: (context, snapshot) {
              final items =
                  snapshot.data?.docs.map((d) => d.data()).toList() ??
                  const <OrderItem>[];
              return Column(
                children: [
                  for (final item in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.quantity}× ${item.nameSnapshot}',
                              style: const TextStyle(
                                color: Color(0xFF374151),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Text(
                            item.subtotal.toStringAsFixed(2),
                            style: const TextStyle(
                              fontFamily: AppConstants.monoFontFamily,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFE5E7EB)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'TOTAL',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Text(
                AppConstants.money(order.total),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  fontFamily: AppConstants.monoFontFamily,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatTime(DateTime? dt) {
    if (dt == null) return '--:--';
    final hour24 = dt.hour;
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${hour12.toString().padLeft(2, '0')}:$minute $period';
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 4.0;
        const dashSpace = 4.0;
        final count = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          children: List.generate(
            count,
            (_) => const Padding(
              padding: EdgeInsets.only(right: dashSpace),
              child: SizedBox(
                width: dashWidth,
                height: 1,
                child: ColoredBox(color: Color(0xFFD1D5DB)),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.status,
    required this.busy,
    required this.onAdvance,
    required this.onCancel,
  });

  final OrderStatus status;
  final bool busy;
  final VoidCallback onAdvance;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      OrderStatus.pending => 'MARK AS PREPARING',
      OrderStatus.preparing => 'MARK AS SERVED',
      OrderStatus.served => 'MARK AS PAID',
      OrderStatus.paid => 'ORDER CLOSED',
    };
    final isPaid = status == OrderStatus.paid;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isPaid || busy ? null : onAdvance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  disabledBackgroundColor: const Color(0xFFE5E7EB),
                  disabledForegroundColor: const Color(0xFF9CA3AF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            if (status == OrderStatus.pending) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: busy ? null : onCancel,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.deleteRed),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'CANCEL ORDER',
                    style: TextStyle(
                      color: AppColors.deleteRed,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
