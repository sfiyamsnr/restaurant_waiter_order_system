import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  final String id;
  final String name;
  final double price;
  final String category;
  final bool available;

  const MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.available,
  });

  MenuItem copyWith({
    String? name,
    double? price,
    String? category,
    bool? available,
  }) {
    return MenuItem(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      available: available ?? this.available,
    );
  }

  factory MenuItem.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? _,
  ) {
    final data = doc.data() ?? {};
    return MenuItem(
      id: doc.id,
      name: data['name'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      category: data['category'] as String? ?? 'Other',
      available: data['available'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'id': id,
    'name': name,
    'price': price,
    'category': category,
    'available': available,
  };
}
