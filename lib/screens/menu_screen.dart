import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/menu_item.dart';
import '../services/firestore_refs.dart';
import '../theme/app_colors.dart';
import '../theme/app_constants.dart';
import '../widgets/circle_icon_button.dart';
import 'menu_item_form_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  Future<void> _addItem() async {
    final result = await showMenuItemFormScreen(context);
    if (result == null) return;
    final doc = FirestoreRefs.menuItems.doc();
    await doc.set(
      MenuItem(
        id: doc.id,
        name: result.name,
        price: result.price,
        category: result.category,
        available: result.available,
      ),
    );
  }

  Future<void> _editItem(MenuItem item) async {
    final result = await showMenuItemFormScreen(context, existing: item);
    if (result == null) return;
    await FirestoreRefs.menuItems.doc(item.id).set(result);
  }

  Future<void> _toggleAvailability(MenuItem item) async {
    await FirestoreRefs.menuItems.doc(item.id).update({
      'available': !item.available,
    });
  }

  Future<void> _deleteItem(MenuItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Item?'),
        content: Text('Remove "${item.name}" from the menu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await FirestoreRefs.menuItems.doc(item.id).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<QuerySnapshot<MenuItem>>(
        stream: FirestoreRefs.menuItems.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!.docs.map((d) => d.data()).toList()
            ..sort((a, b) {
              final byCategory = a.category.compareTo(b.category);
              return byCategory != 0 ? byCategory : a.name.compareTo(b.name);
            });

          final grouped = <String, List<MenuItem>>{};
          for (final item in items) {
            grouped.putIfAbsent(item.category, () => []).add(item);
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Menu',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${items.length} items · tap to toggle',
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CircleIconButton(
                        icon: Icons.add_rounded,
                        onPressed: _addItem,
                        background: AppColors.primaryBlue,
                        foreground: Colors.white,
                        size: 48,
                        tooltip: 'Add Item',
                      ),
                    ],
                  ),
                ),
              ),
              if (items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(onAdd: _addItem),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList.list(
                    children: [
                      for (final entry in grouped.entries) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                          child: Text(
                            entry.key.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        for (final item in entry.value)
                          _MenuItemCard(
                            item: item,
                            onToggleAvailable: () => _toggleAvailability(item),
                            onEdit: () => _editItem(item),
                            onDelete: () => _deleteItem(item),
                          ),
                      ],
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  const _MenuItemCard({
    required this.item,
    required this.onToggleAvailable,
    required this.onEdit,
    required this.onDelete,
  });

  final MenuItem item;
  final VoidCallback onToggleAvailable;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dimmed = !item.available;
    return Opacity(
      opacity: dimmed ? 0.55 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
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
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        AppConstants.money(item.price),
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                          fontFamily: AppConstants.monoFontFamily,
                        ),
                      ),
                      const Text(
                        ' · ',
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                      Text(
                        item.available ? 'Available' : 'Sold Out',
                        style: TextStyle(
                          color: item.available
                              ? AppColors.availableGreen
                              : const Color(0xFF6B7280),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _AvailabilityDot(
              available: item.available,
              onTap: onToggleAvailable,
            ),
            const SizedBox(width: 10),
            CircleIconButton(
              icon: Icons.edit_outlined,
              onPressed: onEdit,
              background: AppColors.editGreyBackground,
              foreground: AppColors.editGrey,
              tooltip: 'Edit',
            ),
            const SizedBox(width: 8),
            CircleIconButton(
              icon: Icons.delete_outline_rounded,
              onPressed: onDelete,
              background: AppColors.deleteRedBackground,
              foreground: AppColors.deleteRed,
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}

/// A tap-to-toggle round indicator: solid green when available, a pale
/// outlined circle when sold out.
class _AvailabilityDot extends StatelessWidget {
  const _AvailabilityDot({required this.available, required this.onTap});

  final bool available;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: available ? AppColors.availableGreen : Colors.transparent,
            border: available
                ? null
                : Border.all(color: const Color(0xFFD1D5DB), width: 2),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.restaurant_menu_rounded,
            size: 64,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 16),
          const Text(
            'No menu items yet',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text('Add your first dish to get started.'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onAdd,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Item'),
          ),
        ],
      ),
    );
  }
}
