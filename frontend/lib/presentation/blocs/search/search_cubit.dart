import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/movie_repository.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final MovieRepository repository;
  Timer? _debounceTimer;

  SearchCubit({required this.repository}) : super(SearchState());

  void onQueryChanged(String query) {
    _debounceTimer?.cancel();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      emit(state.copyWith(query: '', results: [], isSearching: false));
      return;
    }

    emit(state.copyWith(query: trimmed, isSearching: true, errorMessage: null));

    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      search(query: trimmed, page: 1, isRefresh: true);
    });
  }

  Future<void> search({required String query, int page = 1, bool isRefresh = false}) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return;

    if (isRefresh) {
      emit(state.copyWith(isSearching: true, errorMessage: null));
    } else {
      emit(state.copyWith(isLoadingMore: true, errorMessage: null));
    }

    try {
      final res = await repository.searchFilms(keyword: cleanQuery, page: page);
      final newItems = res.items;
      final totalPages = res.paginate?.totalPages ?? 1;
      final totalItems = res.paginate?.totalItems ?? newItems.length;

      // Update history if first page
      final List<String> updatedHistory = List.from(state.recentSearches);
      if (isRefresh && !updatedHistory.contains(cleanQuery)) {
        updatedHistory.insert(0, cleanQuery);
        if (updatedHistory.length > 8) updatedHistory.removeLast();
      }

      emit(state.copyWith(
        query: cleanQuery,
        isSearching: false,
        isLoadingMore: false,
        currentPage: page,
        totalPages: totalPages,
        totalItems: totalItems,
        results: isRefresh ? newItems : [...state.results, ...newItems],
        recentSearches: updatedHistory,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSearching: false,
        isLoadingMore: false,
        errorMessage: 'Lỗi tìm kiếm: $e',
      ));
    }
  }

  Future<void> loadMore() async {
    if (state.isSearching || state.isLoadingMore || !state.hasMore) return;
    await search(query: state.query, page: state.currentPage + 1, isRefresh: false);
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    emit(state.copyWith(query: '', results: [], isSearching: false));
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
