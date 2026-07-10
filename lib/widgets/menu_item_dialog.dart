import 'package:flutter/material.dart';

import '../models/menu_item.dart';

/// Shows a dialog to create or edit a [MenuItem]. Returns the item to save,
/// or null if the user cancelled.
Future<MenuItem?> showMenuItemDialog(
  BuildContext context, {
  MenuItem? existing,
}) {
  return showDialog<MenuItem>(
    context: context,
    builder: (_) => MenuItemDialog(existing: existing),
  );
}

class MenuItemDialog extends StatefulWidget {
  const MenuItemDialog({super.key, this.existing});

  final MenuItem? existing;

  @override
  State<MenuItemDialog> createState() => _MenuItemDialogState();
}

class _MenuItemDialogState extends State<MenuItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _categoryController;
  late bool _available;

  static const _quickCategories = [
    'Starters',
    'Mains',
    'Desserts',
    'Drinks',
  ];

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _priceController = TextEditingController(
      text: existing == null ? '' : existing.price.toStringAsFixed(2),
    );
    _categoryController = TextEditingController(
      text: existing?.category ?? '',
    );
    _available = existing?.available ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final result = MenuItem(
      id: widget.existing?.id ?? '',
      name: _nameController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      category: _categoryController.text.trim(),
      available: _available,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Menu Item' : 'Add Menu Item'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.restaurant_rounded),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Enter a name'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final parsed = double.tryParse((value ?? '').trim());
                  if (parsed == null) return 'Enter a valid price';
                  if (parsed < 0) return 'Price cannot be negative';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_rounded),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Enter a category'
                    : null,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _quickCategories
                    .map(
                      (c) => ActionChip(
                        label: Text(c),
                        onPressed: () =>
                            setState(() => _categoryController.text = c),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Available'),
                value: _available,
                onChanged: (value) => setState(() => _available = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(_isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
