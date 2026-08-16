import 'category_model.dart';
import 'episode_item_model.dart';
import 'film_item_model.dart';

class MovieDetailModel {
  final String id;
  final String name;
  final String slug;
  final String originalName;
  final String thumbUrl;
  final String posterUrl;
  final String description;
  final int totalEpisodes;
  final String currentEpisode;
  final String time;
  final String quality;
  final String language;
  final String? director;
  final String? casts;
  final String year;
  final List<String> genres;
  final List<String> countries;
  final List<CategoryGroup> categoryGroups;
  final List<EpisodeServerModel> episodes;

  MovieDetailModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.originalName,
    required this.thumbUrl,
    required this.posterUrl,
    required this.description,
    required this.totalEpisodes,
    required this.currentEpisode,
    required this.time,
    required this.quality,
    required this.language,
    this.director,
    this.casts,
    this.year = '',
    this.genres = const [],
    this.countries = const [],
    this.categoryGroups = const [],
    this.episodes = const [],
  });

  factory MovieDetailModel.fromJson(Map<String, dynamic> json) {
    final rawEpisodes = json['episodes'] as List<dynamic>? ?? [];
    final episodes = rawEpisodes
        .map((e) => EpisodeServerModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final List<CategoryGroup> groups = [];
    final List<String> genres = [];
    final List<String> countries = [];
    String year = '';

    if (json['category'] != null && json['category'] is Map<String, dynamic>) {
      final catMap = json['category'] as Map<String, dynamic>;
      for (final key in catMap.keys) {
        final val = catMap[key];
        if (val is Map<String, dynamic>) {
          final groupObj = CategoryGroup.fromJson(val);
          groups.add(groupObj);

          final gName = groupObj.name.toLowerCase();
          if (gName.contains('thể loại')) {
            genres.addAll(groupObj.list.map((c) => c.name));
          } else if (gName.contains('quốc gia')) {
            countries.addAll(groupObj.list.map((c) => c.name));
          } else if (gName.contains('năm')) {
            if (groupObj.list.isNotEmpty) {
              year = groupObj.list.first.name;
            }
          }
        }
      }
    }

    if (year.isEmpty && json['year'] != null) {
      year = json['year'].toString();
    }

    return MovieDetailModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Chưa có tên',
      slug: json['slug'] as String? ?? '',
      originalName: json['original_name'] as String? ?? '',
      thumbUrl: json['thumb_url'] as String? ?? '',
      posterUrl: json['poster_url'] as String? ?? json['thumb_url'] as String? ?? '',
      description: json['description'] as String? ?? '',
      totalEpisodes: (json['total_episodes'] as num?)?.toInt() ?? 1,
      currentEpisode: json['current_episode'] as String? ?? 'Full',
      time: json['time'] as String? ?? '',
      quality: json['quality'] as String? ?? 'HD',
      language: json['language'] as String? ?? 'Vietsub',
      director: json['director'] as String?,
      casts: json['casts'] as String?,
      year: year,
      genres: genres,
      countries: countries,
      categoryGroups: groups,
      episodes: episodes,
    );
  }

  FilmItemModel toFilmItem() {
    return FilmItemModel(
      name: name,
      slug: slug,
      originalName: originalName,
      thumbUrl: thumbUrl,
      posterUrl: posterUrl,
      description: description,
      totalEpisodes: totalEpisodes,
      currentEpisode: currentEpisode,
      time: time,
      quality: quality,
      language: language,
      director: director,
      casts: casts,
      year: year,
    );
  }
}

class FilmDetailResponse {
  final String status;
  final MovieDetailModel? movie;
  final String? msg;

  FilmDetailResponse({
    required this.status,
    this.movie,
    this.msg,
  });

  factory FilmDetailResponse.fromJson(Map<String, dynamic> json) {
    MovieDetailModel? movie;
    if (json['movie'] != null && json['movie'] is Map<String, dynamic>) {
      movie = MovieDetailModel.fromJson(json['movie'] as Map<String, dynamic>);
    }

    return FilmDetailResponse(
      status: json['status'] as String? ?? 'success',
      movie: movie,
      msg: json['msg'] as String?,
    );
  }
}
