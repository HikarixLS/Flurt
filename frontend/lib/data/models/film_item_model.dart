class FilmItemModel {
  final String name;
  final String slug;
  final String originalName;
  final String thumbUrl;
  final String posterUrl;
  final String? created;
  final String? modified;
  final String? description;
  final int? totalEpisodes;
  final String? currentEpisode;
  final String? time;
  final String? quality;
  final String? language;
  final String? director;
  final String? casts;
  final String? year;

  FilmItemModel({
    required this.name,
    required this.slug,
    required this.originalName,
    required this.thumbUrl,
    required this.posterUrl,
    this.created,
    this.modified,
    this.description,
    this.totalEpisodes,
    this.currentEpisode,
    this.time,
    this.quality,
    this.language,
    this.director,
    this.casts,
    this.year,
  });

  factory FilmItemModel.fromJson(Map<String, dynamic> json) {
    return FilmItemModel(
      name: json['name'] as String? ?? 'Chưa có tên',
      slug: json['slug'] as String? ?? '',
      originalName: json['original_name'] as String? ?? '',
      thumbUrl: json['thumb_url'] as String? ?? '',
      posterUrl: json['poster_url'] as String? ?? json['thumb_url'] as String? ?? '',
      created: json['created'] as String?,
      modified: json['modified'] as String?,
      description: json['description'] as String?,
      totalEpisodes: (json['total_episodes'] as num?)?.toInt(),
      currentEpisode: json['current_episode'] as String?,
      time: json['time'] as String?,
      quality: json['quality'] as String? ?? 'HD',
      language: json['language'] as String? ?? 'Vietsub',
      director: json['director'] as String?,
      casts: json['casts'] as String?,
      year: json['year']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'slug': slug,
        'original_name': originalName,
        'thumb_url': thumbUrl,
        'poster_url': posterUrl,
        'created': created,
        'modified': modified,
        'description': description,
        'total_episodes': totalEpisodes,
        'current_episode': currentEpisode,
        'time': time,
        'quality': quality,
        'language': language,
        'director': director,
        'casts': casts,
        'year': year,
      };
}
