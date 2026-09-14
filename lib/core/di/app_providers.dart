import 'package:provider/single_child_widget.dart';

/// Composition root.
///
/// This is the *only* place concrete dependencies are constructed and wired
/// together. Widgets and view models never build their own dependencies; they
/// receive them from here via `provider`. As features land (repositories, data
/// sources, view models), their registrations are added to [providers].
List<SingleChildWidget> get providers => const <SingleChildWidget>[
      // Registrations added per feature branch, e.g.:
      //   Provider<SearchRepository>(create: (_) => SearchRepositoryImpl(...)),
      //   ChangeNotifierProvider(create: (ctx) => SearchViewModel(ctx.read())),
    ];
