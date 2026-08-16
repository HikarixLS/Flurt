import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/movie_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final MovieRepository repository;

  HomeCubit({required this.repository}) : super(HomeState());

  Future<void> fetchHomeData() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final results = await Future.wait([
        repository.getNewlyUpdated(page: 1),
        repository.getCategoryFilms(type: 'phim-le', page: 1),
        repository.getCategoryFilms(type: 'phim-bo', page: 1),
        repository.getCategoryFilms(type: 'tv-shows', page: 1),
        repository.getGenreFilms(genreSlug: 'hoat-hinh', page: 1),
      ]);

      final newlyUpdated = results[0].items;
      final singleMovies = results[1].items;
      final seriesMovies = results[2].items;
      final tvShows = results[3].items;
      final animationMovies = results[4].items;

      // Select top 5 for hero spotlight
      final heroMovies = newlyUpdated.take(6).toList();

      emit(state.copyWith(
        isLoading: false,
        heroMovies: heroMovies,
        newlyUpdated: newlyUpdated,
        singleMovies: singleMovies,
        seriesMovies: seriesMovies,
        tvShows: tvShows,
        animationMovies: animationMovies,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải dữ liệu trang chủ: $e',
      ));
    }
  }

  void setHeroIndex(int index) {
    emit(state.copyWith(currentHeroIndex: index));
  }
}
