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
    required this.images,
    required this.sizeGuideImage,
    required this.sizes,
    required this.colorVariants,
    this.story,
    this.launched = true,
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
  final List<String> images;
  final String sizeGuideImage;
  final List<String> sizes;
  final List<ProductColorVariant> colorVariants;
  final String? story;
  final bool launched;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final colorVariants =
        (json['colorVariants'] as List<dynamic>? ?? <dynamic>[])
            .map(
              (item) =>
                  ProductColorVariant.fromJson(item as Map<String, dynamic>),
            )
            .toList();

    final thumbnail = _normalizeMediaRef(json['thumbnail']);
    final parsedImages =
        (json['images'] as List<dynamic>? ?? <dynamic>[])
            .map(_normalizeMediaRef)
            .where((item) => item.trim().isNotEmpty)
            .toList();

    final fallbackImages =
        <String>{
          if (thumbnail.toString().trim().isNotEmpty) thumbnail,
          ...colorVariants
              .map((variant) => variant.image)
              .where((image) => image.trim().isNotEmpty),
        }.toList();

    return ProductModel(
      id: (json['id'] ?? '').toString(),
      category: (json['category'] ?? 'uncategorized').toString(),
      dateAdded:
          DateTime.tryParse((json['dateAdded'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      name: (json['name'] ?? '').toString(),
      shortName: (json['shortName'] ?? '').toString(),
      price:
          json['price'] is num
              ? (json['price'] as num).toDouble()
              : double.tryParse((json['price'] ?? '').toString()) ?? 0.0,
      currency: (json['currency'] ?? 'USD').toString().trim().toUpperCase(),
      unit: (json['unit'] ?? 'piece').toString(),
      availableUnits: (json['availableUnits'] as num?)?.toInt() ?? 0,
      thumbnail: thumbnail,
      images: parsedImages.isNotEmpty ? parsedImages : fallbackImages,
      sizeGuideImage: _normalizeMediaRef(json['sizeGuideImage']),
      sizes:
          json['sizes'] != null
              ? List<String>.from(
                (json['sizes'] as List<dynamic>).map((x) => x.toString()),
              )
              : <String>[],
      story: json['story']?.toString(),
      launched: (json['launched'] as bool?) ?? true,
      colorVariants: colorVariants,
    );
  }

  static String _normalizeMediaRef(dynamic raw) {
    if (raw == null) return '';

    dynamic value = raw;
    if (value is Map<String, dynamic>) {
      value = value['url'] ?? value['image'] ?? value['src'] ?? '';
    }

    var normalized = value.toString().trim();
    if (normalized.length >= 2 &&
        normalized.startsWith('"') &&
        normalized.endsWith('"')) {
      normalized = normalized.substring(1, normalized.length - 1).trim();
    }

    if (normalized.startsWith('https://mock-storage.local/')) {
      return '';
    }

    return normalized;
  }

  bool get isNewArrival {
    final cutoff = DateTime.now().toUtc().subtract(const Duration(days: 30));
    return dateAdded.toUtc().isAfter(cutoff);
  }

  String get primaryImage {
    final normalizedThumbnail = thumbnail.trim();

    if (normalizedThumbnail.isNotEmpty) {
      return normalizedThumbnail;
    }

    for (final image in images) {
      final candidate = image.trim();
      if (candidate.isNotEmpty) {
        return candidate;
      }
    }

    for (final variant in colorVariants) {
      final candidate = variant.image.trim();
      if (candidate.isNotEmpty) {
        return candidate;
      }
    }

    return normalizedThumbnail;
  }

  List<String> get imageCandidates {
    final candidates = <String>[];
    final seen = <String>{};

    void add(String value) {
      final normalized = value.trim();
      if (normalized.isEmpty || seen.contains(normalized)) return;
      seen.add(normalized);
      candidates.add(normalized);
    }

    add(thumbnail);
    for (final image in images) {
      add(image);
    }
    for (final variant in colorVariants) {
      add(variant.image);
    }

    return candidates;
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
        colorName: (json['colorName'] ?? '').toString(),
        colorHex: (json['colorHex'] ?? '#000000').toString(),
        image: ProductModel._normalizeMediaRef(json['image']),
      );
}
