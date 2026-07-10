import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/menu_item.dart';
import '../services/firestore_refs.dart';
import '../theme/app_colors.dart';
import '../theme/app_constants.dart';
import '../widgets/choice_tabs.dart';
import '../widgets/number_stepper_field.dart';
import '../widgets/quantity_stepper.dart';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  static const _categories = ['Mains', 'Drinks', 'Desserts'];

  int _tableNo = 1;
  String _category = _categories.first;
  final Map<String, int> _quantities = {};
  final Map<String, MenuItem> _itemsById = {};
  bool _placing = false;

  int get _totalItems => _quantities.values.fold(0, (a, b) => a + b);

  double get _subtotal => _quantities.entries.fold<double>(
    0,
    (runningTotal, entry) =>
        runningTotal + (_itemsById[entry.key]?.price ?? 0) * entry.value,
  );

  Future<void> _placeOrder() async {
    if (_totalItems == 0 || _placing) return;
    setState(() => _placing = true);
    final drafts = _quantities.entries
        .where((e) => e.value > 0)
        .map((e) {
          final item = _itemsById[e.key]!;
          return OrderDraftItem(
            menuItemId: item.id,
            name: item.name,
            price: item.price,
            quantity: e.value,
          );
        })
        .toList();
    await FirestoreRefs.placeOrder(tableNo: _tableNo, items: drafts);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: Material(
              color: const Color(0xFFE5E7EB),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: const SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(Icons.arrow_back_rounded, size: 18),
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          'New Order',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _FieldLabel('Table Number'),
                NumberStepperField(
                  value: _tableNo,
                  onChanged: (v) => setState(() => _tableNo = v),
                ),
                const SizedBox(height: 16),
                ChoiceTabs(
                  options: _categories,
                  selected: _category,
                  onChanged: (v) => setState(() => _category = v),
                  selectedBackground: const Color(0xFF111827),
                  selectedForeground: Colors.white,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<MenuItem>>(
              stream: FirestoreRefs.menuItems
                  .where('available', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snapshot.data!.docs.map((d) => d.data()).toList()
                  ..sort((a, b) => a.name.compareTo(b.name));
                for (final item in items) {
                  _itemsById[item.id] = item;
                }
                final visible = items
                    .where((i) => i.category == _category)
                    .toList();

                if (visible.isEmpty) {
                  return Center(
                    child: Text(
                      'No available items in $_category',
                      style: const TextStyle(color: Color(0xFF6B7280)),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: visible.length,
                  itemBuilder: (context, index) {
                    final item = visible[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  AppConstants.money(item.price),
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 13,
                                    fontFamily: AppConstants.monoFontFamily,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          QuantityStepper(
                            value: _quantities[item.id] ?? 0,
                            onChanged: (v) => setState(() {
                              _quantities[item.id] = v;
                            }),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _Footer(
            subtotal: _subtotal,
            itemCount: _totalItems,
            enabled: _totalItems > 0 && !_placing,
            onPlaceOrder: _placeOrder,
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.subtotal,
    required this.itemCount,
    required this.enabled,
    required this.onPlaceOrder,
  });

  final double subtotal;
  final int itemCount;
  final bool enabled;
  final VoidCallback onPlaceOrder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal · $itemCount item${itemCount == 1 ? '' : 's'}',
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
                Text(
                  AppConstants.money(subtotal),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: AppConstants.monoFontFamily,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: enabled ? onPlaceOrder : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  disabledBackgroundColor: AppColors.primaryBlue.withValues(
                    alpha: 0.4,
                  ),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'PLACE ORDER',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
          letterSpacing: 0.5,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }
}
