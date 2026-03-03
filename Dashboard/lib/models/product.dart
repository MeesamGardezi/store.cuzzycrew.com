class Product {
  final String id;
  final String name;
  final double price;
  final String thumbnail;
  final String category;
  final int availableUnits;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.thumbnail,
    required this.category,
    required this.availableUnits,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      thumbnail: json['thumbnail'] as String? ?? '',
      category: json['category'] as String? ?? 'uncategorized',
      availableUnits: (json['availableUnits'] as num?)?.toInt() ?? 0,
    );
  }
}
