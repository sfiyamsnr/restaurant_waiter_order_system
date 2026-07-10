import 'package:flutter/material.dart';

import '../models/menu_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_constants.dart';
import '../widgets/choice_tabs.dart';

/// Pushes the full-screen add/edit form for a [MenuItem]. Returns the
/// item to save, or null if the user cancelled.
Future<MenuItem?> showMenuItemFormScreen(
  BuildContext context, {
  MenuItem? existing,
}) {
  return Navigator.of(context).push<MenuItem>(
    MaterialPageRoute(
      builder: (_) => MenuItemFormScreen(existing: existing),
      fullscreenDialog: true,
    ),
  );
}

class MenuItemFormScreen extends StatefulWidget {
  const MenuItemFormScreen({super.key, this.existing});

  final MenuItem? existing;

  @override
  State<MenuItemFormScreen> createState() => _MenuItemFormScreenState();
}

class _MenuItemFormScreenState extends State<MenuItemFormScreen> {
  static const _categories = ['Mains', 'Drinks', 'Desserts'];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late String _category;
  late bool _available;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _priceController = TextEditingController(
      text: existing == null ? '' : existing.price.toStringAsFixed(2),
    );
    _category = _categories.contains(existing?.category)
        ? existing!.category
        : _categories.first;
    _available = existing?.available ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      MenuItem(
        id: widget.existing?.id ?? '',
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        category: _category,
        available: _available,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 8,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
            Text(
              _isEditing ? 'EDIT ITEM' : 'NEW ITEM',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.5,
                color: Colors.black,
              ),
            ),
            TextButton(
              onPressed: _submit,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _FieldLabel('Item Name'),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'e.g. Nasi Lemak Ayam Goreng',
                filled: true,
                fillColor: const Color(0xFFEFF6FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFBFDBFE)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFBFDBFE)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryBlue,
                    width: 1.5,
                  ),
                ),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Enter a name'
                  : null,
            ),
            const SizedBox(height: 20),
            const _FieldLabel('Price (RM)'),
            TextFormField(
              controller: _priceController,
              style: const TextStyle(fontFamily: AppConstants.monoFontFamily),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: const TextStyle(
                  fontFamily: AppConstants.monoFontFamily,
                ),
                filled: true,
                fillColor: const Color(0xFFE5E7EB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryBlue),
                ),
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
            const SizedBox(height: 20),
            const _FieldLabel('Category'),
            ChoiceTabs(
              options: _categories,
              selected: _category,
              onChanged: (value) => setState(() => _category = value),
              selectedBackground: Colors.white,
              selectedForeground: AppColors.primaryBlue,
              selectedBorderColor: AppColors.primaryBlue,
            ),
            const SizedBox(height: 20),
            const _FieldLabel('Status'),
            _AvailabilityToggle(
              value: _available,
              onChanged: (value) => setState(() => _available = value),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailabilityToggle extends StatelessWidget {
  const _AvailabilityToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _segment(
              context,
              'Available',
              value == true,
              () => onChanged(true),
            ),
          ),
          Expanded(
            child: _segment(
              context,
              'Sold Out',
              value == false,
              () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _segment(
    BuildContext context,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : const Color(0xFF6B7280),
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
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
