import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:sqflite/sqflite.dart';

import '../../features/favourites/data/datasources/favourites_local_data_source.dart';
import '../../features/favourites/data/repositories/favourites_repository_impl.dart';
import '../../features/favourites/domain/repositories/favourites_repository.dart';
import '../../features/favourites/presentation/viewmodels/favourites_view_model.dart';
import '../../features/search/data/datasources/book_detail_remote_data_source.dart';
import '../../features/search/data/datasources/search_remote_data_source.dart';
import '../../features/search/data/repositories/book_detail_repository_impl.dart';
import '../../features/search/data/repositories/search_repository_impl.dart';
import '../../features/search/domain/repositories/book_detail_repository.dart';
import '../../features/search/domain/repositories/search_repository.dart';
import '../../features/search/presentation/viewmodels/search_view_model.dart';

/// Composition root.
///
/// The single place concrete dependencies are constructed and wired. Widgets and
/// view models never build their own dependencies; they receive them from here.
/// Each layer is registered behind its abstraction so tests can substitute
/// fakes at the same seam. The [database] is opened once (in `main`) and injected
/// so persistence lives behind the data-source interface.
List<SingleChildWidget> buildProviders(Database database) => [
      Provider<http.Client>(
        create: (_) => http.Client(),
        dispose: (_, client) => client.close(),
      ),
      Provider<SearchRepository>(
        create: (context) => SearchRepositoryImpl(
          remoteDataSource: SearchRemoteDataSourceImpl(
            client: context.read<http.Client>(),
          ),
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
          // Defer so the initial load's notifyListeners never fires during build.
          Future.microtask(viewModel.load);
          return viewModel;
        },
      ),
    ];
