import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/film_item_model.dart';
import '../../../domain/repositories/movie_repository.dart';
import 'movie_detail_state.dart';

class MovieDetailCubit extends Cubit<MovieDetailState> {
  final MovieRepository repository;

  MovieDetailCubit({required this.repository}) : super(MovieDetailState());

  Future<void> fetchMovieDetail(String slug) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final res = await repository.getMovieDetail(slug: slug);
      if (res.movie == null) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Không tìm thấy thông tin phim.',
        ));
        return;
      }

      final movie = res.movie!;
      // Determine stream mode: if stream has m3u8 direct, prefer direct, else embed
      bool isEmbed = true;
      if (movie.episodes.isNotEmpty && movie.episodes.first.items.isNotEmpty) {
        isEmbed = movie.episodes.first.items.first.m3u8.isEmpty;
      }

      // Fetch related movies based on genre or newly updated
      List<FilmItemModel> related = [];
      try {
        if (movie.genres.isNotEmpty) {
          final genreRes = await repository.getNewlyUpdated(page: 1);
          related = genreRes.items.where((f) => f.slug != slug).take(10).toList();
        }
      } catch (_) {}

      emit(state.copyWith(
        isLoading: false,
        movie: movie,
        selectedServerIndex: 0,
        selectedEpisodeIndex: 0,
        isEmbedMode: isEmbed,
        relatedMovies: related,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Lỗi tải chi tiết phim: $e',
      ));
    }
  }

  void selectServer(int index) {
    if (state.movie == null) return;
    if (index >= 0 && index < state.movie!.episodes.length) {
      final server = state.movie!.episodes[index];
      final currentEpIdx = state.selectedEpisodeIndex.clamp(0, (server.items.length - 1).clamp(0, 9999));
      emit(state.copyWith(
        selectedServerIndex: index,
        selectedEpisodeIndex: currentEpIdx,
      ));
    }
  }

  void selectEpisode(int episodeIndex) {
    final server = state.currentServer;
    if (server == null) return;
    if (episodeIndex >= 0 && episodeIndex < server.items.length) {
      emit(state.copyWith(selectedEpisodeIndex: episodeIndex));
    }
  }

  void toggleCinemaMode() {
    emit(state.copyWith(isCinemaMode: !state.isCinemaMode));
  }

  void toggleEmbedMode() {
    emit(state.copyWith(isEmbedMode: !state.isEmbedMode));
  }
}
