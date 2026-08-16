class PaginateModel {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;

  PaginateModel({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
  });

  factory PaginateModel.fromJson(Map<String, dynamic> json) {
    return PaginateModel(
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      totalPages: (json['total_page'] ?? json['total_pages'] as num?)?.toInt() ?? 1,
      totalItems: (json['total_items'] as num?)?.toInt() ?? 0,
      itemsPerPage: (json['items_per_page'] as num?)?.toInt() ?? 24,
    );
  }

  Map<String, dynamic> toJson() => {
        'current_page': currentPage,
        'total_page': totalPages,
        'total_items': totalItems,
        'items_per_page': itemsPerPage,
      };
}
