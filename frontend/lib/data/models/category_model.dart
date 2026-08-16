class CategoryItem {
  final String id;
  final String name;

  CategoryItem({
    required this.id,
    required this.name,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class CategoryGroup {
  final String id;
  final String name;
  final List<CategoryItem> list;

  CategoryGroup({
    required this.id,
    required this.name,
    required this.list,
  });

  factory CategoryGroup.fromJson(Map<String, dynamic> json) {
    final group = json['group'] as Map<String, dynamic>? ?? {};
    final rawList = json['list'] as List<dynamic>? ?? [];

    return CategoryGroup(
      id: group['id']?.toString() ?? '',
      name: group['name'] as String? ?? '',
      list: rawList.map((e) => CategoryItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
