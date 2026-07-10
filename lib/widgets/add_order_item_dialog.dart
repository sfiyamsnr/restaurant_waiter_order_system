import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/menu_item.dart';
import '../services/firestore_refs.dart';
import '../theme/app_constants.dart';

class AddOrderItemResult {
  const AddOrderItemResult({required this.menuItem, required this.quantity});

  final MenuItem menuItem;
  final int quantity;
}

/// Shows a dialog to pick an available menu item and a quantity. Returns
/// the selection, or null if the user cancelled.
Future<AddOrderItemResult?> showAddOrderItemDialog(BuildContext context) {
  return showDialog<AddOrderItemResult>(
    context: context,
    builder: (_) => const AddOrderItemDialog(),
  );
}

class AddOrderItemDialog extends StatefulWidget {
  const AddOrderItemDialog({super.key});

  @override
  State<AddOrderItemDialog> createState() => _AddOrderItemDialogState();
}

class _AddOrderItemDialogState extends State<AddOrderItemDialog> {
  MenuItem? _selected;
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Item'),
      content: SizedBox(
        width: 360,
        child: StreamBuilder<QuerySnapshot<MenuItem>>(
          stream: FirestoreRefs.menuItems
              .where('available', isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (!snapshot.hasData) {
              return const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final items = snapshot.data!.docs.map((d) => d.data()).toList()
              ..sort((a, b) => a.name.compareTo(b.name));

            if (items.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No available menu items. Add some in the Menu tab first.',
                ),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<MenuItem>(
                  initialValue: _selected,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Menu item'),
                  items: items
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            '${item.name} · ${AppConstants.money(item.price)}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _selected = value),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Quantity'),
                    Row(
                      children: [
                        IconButton.outlined(
                          onPressed: _quantity > 1
                              ? () => setState(() => _quantity--)
                              : null,
                          icon: const Icon(Icons.remove_rounded),
                        ),
                        SizedBox(
                          width: 32,
                          child: Text(
                            '$_quantity',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        IconButton.outlined(
                          onPressed: () => setState(() => _quantity++),
                          icon: const Icon(Icons.add_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _selected == null
              ? null
              : () => Navigator.of(context).pop(
                  AddOrderItemResult(menuItem: _selected!, quantity: _quantity),
                ),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
