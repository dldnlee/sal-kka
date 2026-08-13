enum Category { delivery, fashion, tech, hobby, beauty }

extension CategoryLabel on Category {
  String get label {
    switch (this) {
      case Category.delivery:
        return '배달음식';
      case Category.fashion:
        return '패션';
      case Category.tech:
        return 'IT·가전';
      case Category.hobby:
        return '취미·게임';
      case Category.beauty:
        return '뷰티';
    }
  }
}

enum ItemStatus { cooling, saved, bought }

class ShoppingItem {
  final String id;
  final String name;
  final double price;
  final Category category;
  final double hourlyWage;
  final DateTime createdAt;
  final DateTime cooldownEndsAt;
  ItemStatus status;
  DateTime? decisionAt;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.hourlyWage,
    required this.createdAt,
    required this.cooldownEndsAt,
    this.status = ItemStatus.cooling,
    this.decisionAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'category': category.name,
        'hourlyWage': hourlyWage,
        'createdAt': createdAt.toIso8601String(),
        'cooldownEndsAt': cooldownEndsAt.toIso8601String(),
        'status': status.name,
        'decisionAt': decisionAt?.toIso8601String(),
      };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        category: Category.values.firstWhere(
          (c) => c.name == json['category'],
          orElse: () => Category.fashion,
        ),
        hourlyWage: (json['hourlyWage'] as num).toDouble(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        cooldownEndsAt: DateTime.parse(json['cooldownEndsAt'] as String),
        status: ItemStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => ItemStatus.cooling,
        ),
        decisionAt: json['decisionAt'] != null
            ? DateTime.parse(json['decisionAt'] as String)
            : null,
      );
}
