import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../features/search/data/datasources/search_remote_data_source.dart';
import '../../features/search/data/repositories/search_repository_impl.dart';
import '../../features/search/domain/repositories/search_repository.dart';
import '../../features/search/presentation/viewmodels/search_view_model.dart';

/// Composition root.
///
/// The single place concrete dependencies are constructed and wired. Widgets and
/// view models never build their own dependencies; they receive them from here.
/// Each layer is registered behind its abstraction so tests can substitute
/// fakes at the same seam.
List<SingleChildWidget> get providers => [
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
      ChangeNotifierProvider<SearchViewModel>(
        create: (context) =>
            SearchViewModel(repository: context.read<SearchRepository>()),
      ),
    ];
