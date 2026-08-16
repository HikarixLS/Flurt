import '../datasources/nguonc_remote_datasource.dart';
import '../models/film_detail_response.dart';
import '../models/film_list_response.dart';
import '../../domain/repositories/movie_repository.dart';

class MovieRepositoryImpl implements MovieRepository {
  final NguonCRemoteDataSource remoteDataSource;

  MovieRepositoryImpl({NguonCRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? NguonCRemoteDataSourceImpl();

  @override
  Future<FilmListResponse> getNewlyUpdated({int page = 1}) {
    return remoteDataSource.getNewlyUpdated(page: page);
  }

  @override
  Future<FilmListResponse> getCategoryFilms({required String type, int page = 1}) {
    return remoteDataSource.getCategoryFilms(type: type, page: page);
  }

  @override
  Future<FilmListResponse> getGenreFilms({required String genreSlug, int page = 1}) {
    return remoteDataSource.getGenreFilms(genreSlug: genreSlug, page: page);
  }

  @override
  Future<FilmListResponse> getCountryFilms({required String countrySlug, int page = 1}) {
    return remoteDataSource.getCountryFilms(countrySlug: countrySlug, page: page);
  }

  @override
  Future<FilmListResponse> getYearFilms({required String year, int page = 1}) {
    return remoteDataSource.getYearFilms(year: year, page: page);
  }

  @override
  Future<FilmDetailResponse> getMovieDetail({required String slug}) {
    return remoteDataSource.getMovieDetail(slug: slug);
  }

  @override
  Future<FilmListResponse> searchFilms({required String keyword, int page = 1}) {
    return remoteDataSource.searchFilms(keyword: keyword, page: page);
  }
}
