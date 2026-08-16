import '../../../data/models/film_item_model.dart';

class SearchState {
  final String query;
  final bool isSearching;
  final bool isLoadingMore;
  final String? errorMessage;
  final List<FilmItemModel> results;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final List<String> recentSearches;

  SearchState({
    this.query = '',
    this.isSearching = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.results = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.recentSearches = const [
      'Avatar',
      'Đấu La Đại Lục',
      'One Piece',
      'To To',
      'Cực Hạn'
    ],
  });

  bool get hasMore => currentPage < totalPages;

  SearchState copyWith({
    String? query,
    bool? isSearching,
    bool? isLoadingMore,
    String? errorMessage,
    List<FilmItemModel>? results,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    List<String>? recentSearches,
  }) {
    return SearchState(
      query: query ?? this.query,
      isSearching: isSearching ?? this.isSearching,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      results: results ?? this.results,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      recentSearches: recentSearches ?? this.recentSearches,
    );
  }
}
