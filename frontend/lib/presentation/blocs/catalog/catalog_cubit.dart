import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/film_list_response.dart';
import '../../../domain/repositories/movie_repository.dart';
import 'catalog_state.dart';

class CatalogCubit extends Cubit<CatalogState> {
  final MovieRepository repository;

  CatalogCubit({required this.repository}) : super(CatalogState());

  Future<void> initCatalog({
    String? type,
    String? genre,
    String? country,
    String? year,
  }) async {
    emit(state.copyWith(
      selectedType: type ?? state.selectedType,
      selectedGenre: genre,
      selectedCountry: country,
      selectedYear: year,
    ));
    await fetchMovies(page: 1, isRefresh: true);
  }

  Future<void> fetchMovies({int page = 1, bool isRefresh = false}) async {
    if (isRefresh) {
      emit(state.copyWith(isLoading: true, errorMessage: null));
    } else {
      emit(state.copyWith(isLoadingMore: true, errorMessage: null));
    }

    try {
      FilmListResponse res;

      if (state.selectedGenre != null) {
        res = await repository.getGenreFilms(genreSlug: state.selectedGenre!, page: page);
      } else if (state.selectedCountry != null) {
        res = await repository.getCountryFilms(countrySlug: state.selectedCountry!, page: page);
      } else if (state.selectedYear != null) {
        res = await repository.getYearFilms(year: state.selectedYear!, page: page);
      } else if (state.selectedType != 'all') {
        res = await repository.getCategoryFilms(type: state.selectedType, page: page);
      } else {
        res = await repository.getNewlyUpdated(page: page);
      }

      final newItems = res.items;
      final totalPages = res.paginate?.totalPages ?? 1;
      final totalItems = res.paginate?.totalItems ?? newItems.length;

      emit(state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        currentPage: page,
        totalPages: totalPages,
        totalItems: totalItems,
        movies: isRefresh ? newItems : [...state.movies, ...newItems],
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: 'Lỗi tải danh sách phim: $e',
      ));
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    await fetchMovies(page: state.currentPage + 1, isRefresh: false);
  }

  void setType(String type) {
    emit(state.copyWith(
      selectedType: type,
      clearGenre: true,
      clearCountry: true,
      clearYear: true,
    ));
    fetchMovies(page: 1, isRefresh: true);
  }

  void setGenre(String? genre) {
    emit(state.copyWith(
      selectedGenre: genre,
      clearGenre: genre == null,
      clearCountry: true,
      clearYear: true,
    ));
    fetchMovies(page: 1, isRefresh: true);
  }

  void setCountry(String? country) {
    emit(state.copyWith(
      selectedCountry: country,
      clearCountry: country == null,
      clearGenre: true,
      clearYear: true,
    ));
    fetchMovies(page: 1, isRefresh: true);
  }

  void setYear(String? year) {
    emit(state.copyWith(
      selectedYear: year,
      clearYear: year == null,
      clearGenre: true,
      clearCountry: true,
    ));
    fetchMovies(page: 1, isRefresh: true);
  }

  void resetFilters() {
    emit(CatalogState());
    fetchMovies(page: 1, isRefresh: true);
  }
}
