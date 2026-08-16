import 'package:go_router/go_router.dart';
import '../../presentation/views/catalog/catalog_view.dart';
import '../../presentation/views/detail/movie_detail_view.dart';
import '../../presentation/views/home/home_view.dart';
import '../../presentation/views/search/search_view.dart';
import '../../presentation/views/watch_party/watch_party_view.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeView(),
    ),
    GoRoute(
      path: '/catalog',
      builder: (context, state) {
        final type = state.uri.queryParameters['type'];
        final genre = state.uri.queryParameters['genre'];
        final country = state.uri.queryParameters['country'];
        final year = state.uri.queryParameters['year'];

        return CatalogView(
          initialType: type,
          initialGenre: genre,
          initialCountry: country,
          initialYear: year,
        );
      },
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) {
        final query = state.uri.queryParameters['q'];
        return SearchView(initialQuery: query);
      },
    ),
    GoRoute(
      path: '/film/:slug',
      builder: (context, state) {
        final slug = state.pathParameters['slug'] ?? '';
        return MovieDetailView(slug: slug);
      },
    ),
    GoRoute(
      path: '/watch-party',
      builder: (context, state) {
        final roomId = state.uri.queryParameters['room'] ?? state.uri.queryParameters['roomId'];
        return WatchPartyView(roomId: roomId);
      },
    ),
  ],
);
