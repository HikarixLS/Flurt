import '../../../data/models/film_item_model.dart';

class HomeState {
  final bool isLoading;
  final String? errorMessage;
  final List<FilmItemModel> heroMovies;
  final List<FilmItemModel> newlyUpdated;
  final List<FilmItemModel> singleMovies;
  final List<FilmItemModel> seriesMovies;
  final List<FilmItemModel> tvShows;
  final List<FilmItemModel> animationMovies;
  final int currentHeroIndex;

  HomeState({
    this.isLoading = false,
    this.errorMessage,
    this.heroMovies = const [],
    this.newlyUpdated = const [],
    this.singleMovies = const [],
    this.seriesMovies = const [],
    this.tvShows = const [],
    this.animationMovies = const [],
    this.currentHeroIndex = 0,
  });

  HomeState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<FilmItemModel>? heroMovies,
    List<FilmItemModel>? newlyUpdated,
    List<FilmItemModel>? singleMovies,
    List<FilmItemModel>? seriesMovies,
    List<FilmItemModel>? tvShows,
    List<FilmItemModel>? animationMovies,
    int? currentHeroIndex,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      heroMovies: heroMovies ?? this.heroMovies,
      newlyUpdated: newlyUpdated ?? this.newlyUpdated,
      singleMovies: singleMovies ?? this.singleMovies,
      seriesMovies: seriesMovies ?? this.seriesMovies,
      tvShows: tvShows ?? this.tvShows,
      animationMovies: animationMovies ?? this.animationMovies,
      currentHeroIndex: currentHeroIndex ?? this.currentHeroIndex,
    );
  }
}
