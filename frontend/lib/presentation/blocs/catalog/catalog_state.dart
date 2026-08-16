import '../../../data/models/film_item_model.dart';

class CatalogState {
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final String selectedType; // 'all', 'phim-le', 'phim-bo', 'tv-shows', 'dang-chieu'
  final String? selectedGenre;
  final String? selectedCountry;
  final String? selectedYear;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final List<FilmItemModel> movies;

  CatalogState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.selectedType = 'all',
    this.selectedGenre,
    this.selectedCountry,
    this.selectedYear,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.movies = const [],
  });

  bool get hasMore => currentPage < totalPages;

  CatalogState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    String? selectedType,
    String? selectedGenre,
    bool clearGenre = false,
    String? selectedCountry,
    bool clearCountry = false,
    String? selectedYear,
    bool clearYear = false,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    List<FilmItemModel>? movies,
  }) {
    return CatalogState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      selectedType: selectedType ?? this.selectedType,
      selectedGenre: clearGenre ? null : (selectedGenre ?? this.selectedGenre),
      selectedCountry: clearCountry ? null : (selectedCountry ?? this.selectedCountry),
      selectedYear: clearYear ? null : (selectedYear ?? this.selectedYear),
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      movies: movies ?? this.movies,
    );
  }
}
