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
    required this.description,
    required this.itemCount,
    required this.featured,
    required this.sortOrder,
    required this.tags,
  });

  final String name;
  final String slug;
  final String thumbnail;
  final String description;
  final int itemCount;
  final bool featured;
  final String id;
  final int sortOrder;
  final List<String> tags;

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json["id"],
    name: json["name"],
    slug: json["slug"],
    thumbnail: json["thumbnail"],
    description: json["description"],
    itemCount: json["itemCount"],
    featured: json["featured"],
    sortOrder: json["sortOrder"],
    tags: List<String>.from(json["tags"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "thumbnail": thumbnail,
    "description": description,
    "itemCount": itemCount,
    "featured": featured,
    "sortOrder": sortOrder,
    "tags": List<dynamic>.from(tags.map((x) => x)),
  };
}
