import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:sqflite/sqflite.dart';

import '../../features/favourites/data/datasources/favourites_local_data_source.dart';
import '../../features/favourites/data/repositories/favourites_repository_impl.dart';
import '../../features/favourites/domain/repositories/favourites_repository.dart';
import '../../features/favourites/presentation/viewmodels/favourites_view_model.dart';
import '../../features/search/data/datasources/book_detail_remote_data_source.dart';
import '../../features/search/data/datasources/search_cache_data_source.dart';
import '../../features/search/data/datasources/search_remote_data_source.dart';
import '../../features/search/data/repositories/book_detail_repository_impl.dart';
import '../../features/search/data/repositories/search_repository_impl.dart';
import '../../features/search/domain/repositories/book_detail_repository.dart';
import '../../features/search/domain/repositories/search_repository.dart';
import '../../features/search/presentation/viewmodels/search_view_model.dart';
import '../network/connectivity_checker.dart';
import '../network/connectivity_view_model.dart';
import '../theme/theme_preference_store.dart';
import '../theme/theme_view_model.dart';

List<SingleChildWidget> buildProviders(Database database) => [
  Provider<http.Client>(
    create: (_) => http.Client(),
    dispose: (_, client) => client.close(),
  ),
  Provider<ConnectivityChecker>(create: (_) => ConnectivityCheckerImpl()),
  Provider<SearchRepository>(
    create: (context) => SearchRepositoryImpl(
      remoteDataSource: SearchRemoteDataSourceImpl(
        client: context.read<http.Client>(),
      ),
      cache: SearchCacheDataSourceImpl(database: database),
      connectivity: context.read<ConnectivityChecker>(),
    ),
  ),
  Provider<BookDetailRepository>(
    create: (context) => BookDetailRepositoryImpl(
      remoteDataSource: BookDetailRemoteDataSourceImpl(
        client: context.read<http.Client>(),
      ),
    ),
  ),
  Provider<FavouritesRepository>(
    create: (_) => FavouritesRepositoryImpl(
      localDataSource: FavouritesLocalDataSourceImpl(database: database),
    ),
  ),
  ChangeNotifierProvider<SearchViewModel>(
    create: (context) =>
        SearchViewModel(repository: context.read<SearchRepository>()),
  ),
  ChangeNotifierProvider<FavouritesViewModel>(
    create: (context) {
      final viewModel = FavouritesViewModel(
        repository: context.read<FavouritesRepository>(),
      );
      Future.microtask(viewModel.load);
      return viewModel;
    },
  ),
  ChangeNotifierProvider<ConnectivityViewModel>(
    create: (context) {
      final viewModel = ConnectivityViewModel(
        checker: context.read<ConnectivityChecker>(),
      );
      Future.microtask(viewModel.start);
      return viewModel;
    },
  ),
  ChangeNotifierProvider<ThemeViewModel>(
    create: (_) {
      final viewModel = ThemeViewModel(
        store: ThemePreferenceStoreImpl(database: database),
      );
      Future.microtask(viewModel.load);
      return viewModel;
    },
  ),
];
