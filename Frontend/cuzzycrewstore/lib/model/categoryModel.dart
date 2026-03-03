import 'dart:convert';

List<CategoryModel> categoryModelFromJson(String str) {
  final Map<String, dynamic> decoded = json.decode(str);
  final List<dynamic> rawCategories = decoded['categories'] ?? <dynamic>[];
  return rawCategories
      .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
      .toList();
}

String categoryModelToJson(List<CategoryModel> data) =>
    json.encode({'categories': data.map((item) => item.toJson()).toList()});

class CategoryModel {
  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.thumbnail,
    required this.launched,
    required this.description,
    required this.itemCount,
    required this.featured,
    required this.sortOrder,
    required this.tags,
  });

  final String name;
  final String slug;
  final String thumbnail;
  final bool launched;
  final String description;
  final int itemCount;
  final bool featured;
  final String id;
  final int sortOrder;
  final List<String> tags;

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json["id"] as String? ?? '',
    name: json["name"] as String? ?? '',
    slug: json["slug"] as String? ?? '',
    thumbnail: json["thumbnail"] as String? ?? '',
    launched: json["launched"] as bool? ?? false,
    description: json["description"] as String? ?? '',
    itemCount: json["itemCount"] as int? ?? 0,
    featured: json["featured"] as bool? ?? false,
    sortOrder: json["sortOrder"] as int? ?? 999,
    tags:
        json["tags"] != null
            ? List<String>.from(
              (json["tags"] as List<dynamic>).map((x) => x.toString()),
            )
            : <String>[],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "thumbnail": thumbnail,
    "launched": launched,
    "description": description,
    "itemCount": itemCount,
    "featured": featured,
    "sortOrder": sortOrder,
    "tags": List<dynamic>.from(tags.map((x) => x)),
  };
}
