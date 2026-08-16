import '../../data/models/film_detail_response.dart';
import '../../data/models/film_list_response.dart';

abstract class MovieRepository {
  Future<FilmListResponse> getNewlyUpdated({int page = 1});
  Future<FilmListResponse> getCategoryFilms({required String type, int page = 1});
  Future<FilmListResponse> getGenreFilms({required String genreSlug, int page = 1});
  Future<FilmListResponse> getCountryFilms({required String countrySlug, int page = 1});
  Future<FilmListResponse> getYearFilms({required String year, int page = 1});
  Future<FilmDetailResponse> getMovieDetail({required String slug});
  Future<FilmListResponse> searchFilms({required String keyword, int page = 1});
}
