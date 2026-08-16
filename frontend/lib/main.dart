import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/nguonc_remote_datasource.dart';
import 'data/repositories/movie_repository_impl.dart';
import 'domain/repositories/movie_repository.dart';
import 'presentation/blocs/catalog/catalog_cubit.dart';
import 'presentation/blocs/detail/movie_detail_cubit.dart';
import 'presentation/blocs/home/home_cubit.dart';
import 'presentation/blocs/search/search_cubit.dart';
import 'presentation/blocs/watch_party/watch_party_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FlurtApp());
}

class FlurtApp extends StatelessWidget {
  const FlurtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<MovieRepository>(
          create: (_) => MovieRepositoryImpl(
            remoteDataSource: NguonCRemoteDataSourceImpl(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<HomeCubit>(
            create: (context) => HomeCubit(
              repository: context.read<MovieRepository>(),
            ),
          ),
          BlocProvider<CatalogCubit>(
            create: (context) => CatalogCubit(
              repository: context.read<MovieRepository>(),
            ),
          ),
          BlocProvider<SearchCubit>(
            create: (context) => SearchCubit(
              repository: context.read<MovieRepository>(),
            ),
          ),
          BlocProvider<MovieDetailCubit>(
            create: (context) => MovieDetailCubit(
              repository: context.read<MovieRepository>(),
            ),
          ),
          BlocProvider<WatchPartyCubit>(
            create: (_) => WatchPartyCubit(),
          ),
        ],
        child: MaterialApp.router(
          title: 'Flurt - Xem Phim & Watch Party Trực Tuyến',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
