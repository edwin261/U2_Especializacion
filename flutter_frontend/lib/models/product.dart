class Product {
  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.createdBy,
    required this.creatorName,
  });

  final int id;
  final String name;
  final double price;
  final int createdBy;
  final String creatorName;

  factory Product.fromJson(Map<String, dynamic> json) {
    final user = json['User'];

    return Product(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      price: _toDouble(json['price']),
      createdBy: _toInt(json['created_by']),
      creatorName: user is Map<String, dynamic>
          ? user['name']?.toString() ?? 'Sin creador'
          : 'Sin creador',
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
