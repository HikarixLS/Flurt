import 'film_item_model.dart';
import 'paginate_model.dart';

class FilmListResponse {
  final String status;
  final String? msg;
  final List<FilmItemModel> items;
  final PaginateModel? paginate;

  FilmListResponse({
    required this.status,
    this.msg,
    required this.items,
    this.paginate,
  });

  factory FilmListResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final items = rawItems
        .map((e) => FilmItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    PaginateModel? paginate;
    if (json['paginate'] != null) {
      paginate = PaginateModel.fromJson(json['paginate'] as Map<String, dynamic>);
    }

    return FilmListResponse(
      status: json['status'] as String? ?? 'success',
      msg: json['msg'] as String?,
      items: items,
      paginate: paginate,
    );
  }
}
