class Category {
  final String id;
  final String name;
  final String thumbnail;
  final bool launched;

  Category({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.launched,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      launched: json['launched'] as bool? ?? false,
    );
  }
}
