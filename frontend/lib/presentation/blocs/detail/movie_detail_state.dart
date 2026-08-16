import '../../../data/models/episode_item_model.dart';
import '../../../data/models/film_detail_response.dart';
import '../../../data/models/film_item_model.dart';

class MovieDetailState {
  final bool isLoading;
  final String? errorMessage;
  final MovieDetailModel? movie;
  final int selectedServerIndex;
  final int selectedEpisodeIndex;
  final bool isCinemaMode;
  final bool isEmbedMode;
  final List<FilmItemModel> relatedMovies;

  MovieDetailState({
    this.isLoading = false,
    this.errorMessage,
    this.movie,
    this.selectedServerIndex = 0,
    this.selectedEpisodeIndex = 0,
    this.isCinemaMode = false,
    this.isEmbedMode = true,
    this.relatedMovies = const [],
  });

  EpisodeServerModel? get currentServer {
    if (movie == null || movie!.episodes.isEmpty) return null;
    if (selectedServerIndex < 0 || selectedServerIndex >= movie!.episodes.length) {
      return movie!.episodes.first;
    }
    return movie!.episodes[selectedServerIndex];
  }

  EpisodeItemModel? get currentEpisode {
    final server = currentServer;
    if (server == null || server.items.isEmpty) return null;
    if (selectedEpisodeIndex < 0 || selectedEpisodeIndex >= server.items.length) {
      return server.items.first;
    }
    return server.items[selectedEpisodeIndex];
  }

  String get activeStreamUrl {
    final ep = currentEpisode;
    if (ep == null) return '';
    return ep.activeStreamUrl;
  }

  MovieDetailState copyWith({
    bool? isLoading,
    String? errorMessage,
    MovieDetailModel? movie,
    int? selectedServerIndex,
    int? selectedEpisodeIndex,
    bool? isCinemaMode,
    bool? isEmbedMode,
    List<FilmItemModel>? relatedMovies,
  }) {
    return MovieDetailState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      movie: movie ?? this.movie,
      selectedServerIndex: selectedServerIndex ?? this.selectedServerIndex,
      selectedEpisodeIndex: selectedEpisodeIndex ?? this.selectedEpisodeIndex,
      isCinemaMode: isCinemaMode ?? this.isCinemaMode,
      isEmbedMode: isEmbedMode ?? this.isEmbedMode,
      relatedMovies: relatedMovies ?? this.relatedMovies,
    );
  }
}
