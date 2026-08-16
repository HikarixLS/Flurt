class EpisodeItemModel {
  final String name;
  final String slug;
  final String embed;
  final String m3u8;

  EpisodeItemModel({
    required this.name,
    required this.slug,
    this.embed = '',
    this.m3u8 = '',
  });

  factory EpisodeItemModel.fromJson(Map<String, dynamic> json) {
    return EpisodeItemModel(
      name: json['name'] as String? ?? 'Tập',
      slug: json['slug'] as String? ?? '',
      embed: json['embed'] as String? ?? '',
      m3u8: json['m3u8'] as String? ?? '',
    );
  }

  String get activeStreamUrl => m3u8.isNotEmpty ? m3u8 : embed;
  bool get isDirectStream => m3u8.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'name': name,
        'slug': slug,
        'embed': embed,
        'm3u8': m3u8,
      };
}

class EpisodeServerModel {
  final String serverName;
  final List<EpisodeItemModel> items;

  EpisodeServerModel({
    required this.serverName,
    required this.items,
  });

  factory EpisodeServerModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final items = rawItems
        .map((e) => EpisodeItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return EpisodeServerModel(
      serverName: json['server_name'] as String? ?? 'Server',
      items: items,
    );
  }

  Map<String, dynamic> toJson() => {
        'server_name': serverName,
        'items': items.map((e) => e.toJson()).toList(),
      };
}
