import '../models/film_detail_response.dart';
import '../models/film_list_response.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';

abstract class NguonCRemoteDataSource {
  Future<FilmListResponse> getNewlyUpdated({int page = 1});
  Future<FilmListResponse> getCategoryFilms({required String type, int page = 1});
  Future<FilmListResponse> getGenreFilms({required String genreSlug, int page = 1});
  Future<FilmListResponse> getCountryFilms({required String countrySlug, int page = 1});
  Future<FilmListResponse> getYearFilms({required String year, int page = 1});
  Future<FilmDetailResponse> getMovieDetail({required String slug});
  Future<FilmListResponse> searchFilms({required String keyword, int page = 1});
}

class NguonCRemoteDataSourceImpl implements NguonCRemoteDataSource {
  final ApiClient apiClient;

  NguonCRemoteDataSourceImpl({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  @override
  Future<FilmListResponse> getNewlyUpdated({int page = 1}) async {
    final data = await apiClient.get(
      ApiConstants.newlyUpdated,
      queryParameters: {'page': page},
    );
    return FilmListResponse.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<FilmListResponse> getCategoryFilms({required String type, int page = 1}) async {
    final data = await apiClient.get(
      '${ApiConstants.filmList}/$type',
      queryParameters: {'page': page},
    );
    return FilmListResponse.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<FilmListResponse> getGenreFilms({required String genreSlug, int page = 1}) async {
    final data = await apiClient.get(
      '${ApiConstants.genre}/$genreSlug',
      queryParameters: {'page': page},
    );
    return FilmListResponse.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<FilmListResponse> getCountryFilms({required String countrySlug, int page = 1}) async {
    final data = await apiClient.get(
      '${ApiConstants.country}/$countrySlug',
      queryParameters: {'page': page},
    );
    return FilmListResponse.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<FilmListResponse> getYearFilms({required String year, int page = 1}) async {
    final data = await apiClient.get(
      '${ApiConstants.releaseYear}/$year',
      queryParameters: {'page': page},
    );
    return FilmListResponse.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<FilmDetailResponse> getMovieDetail({required String slug}) async {
    final data = await apiClient.get(
      '${ApiConstants.filmDetail}/$slug',
      enableCache: false, // detail should be fresh
    );
    return FilmDetailResponse.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<FilmListResponse> searchFilms({required String keyword, int page = 1}) async {
    final data = await apiClient.get(
      ApiConstants.search,
      queryParameters: {'keyword': keyword, 'page': page},
    );
    return FilmListResponse.fromJson(data as Map<String, dynamic>);
  }
}
