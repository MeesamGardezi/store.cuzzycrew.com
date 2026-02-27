import 'dart:convert';

List<ProductModel> productModelFromJson(String str) {
  final Map<String, dynamic> decoded = json.decode(str);
  final List<dynamic> rawProducts = decoded['products'] ?? <dynamic>[];
  return rawProducts
      .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
      .toList();
}

class ProductModel {
  ProductModel({
    required this.id,
    required this.category,
    required this.dateAdded,
    required this.name,
    required this.shortName,
    required this.price,
    required this.currency,
    required this.unit,
    required this.availableUnits,
    required this.thumbnail,
    required this.sizeGuideImage,
    required this.sizes,
    required this.colorVariants,
  });

  final String id;
  final String category;
  final DateTime dateAdded;
  final String name;
  final String shortName;
  final double price;
  final String currency;
  final String unit;
  final int availableUnits;
  final String thumbnail;
  final String sizeGuideImage;
  final List<String> sizes;
  final List<ProductColorVariant> colorVariants;

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json['id'] ?? '',
    category: json['category'] ?? 'uncategorized',
    dateAdded:
        DateTime.tryParse(json['dateAdded'] ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
    name: json['name'] ?? '',
    shortName: json['shortName'] ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    currency: json['currency'] ?? 'USD',
    unit: json['unit'] ?? 'piece',
    availableUnits: json['availableUnits'] ?? 0,
    thumbnail: json['thumbnail'] ?? '',
    sizeGuideImage: json['sizeGuideImage'] ?? '',
    sizes: List<String>.from(json['sizes'] ?? <String>[]),
    colorVariants:
        (json['colorVariants'] as List<dynamic>? ?? <dynamic>[])
            .map(
              (item) =>
                  ProductColorVariant.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
  );

  bool get isNewArrival {
    final cutoff = DateTime.now().toUtc().subtract(const Duration(days: 30));
    return dateAdded.toUtc().isAfter(cutoff);
  }
}

class ProductColorVariant {
  ProductColorVariant({
    required this.colorName,
    required this.colorHex,
    required this.image,
  });

  final String colorName;
  final String colorHex;
  final String image;

  factory ProductColorVariant.fromJson(Map<String, dynamic> json) =>
      ProductColorVariant(
        colorName: json['colorName'] ?? '',
        colorHex: json['colorHex'] ?? '#000000',
        image: json['image'] ?? '',
      );
}
