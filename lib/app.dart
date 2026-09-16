import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'core/di/app_providers.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_view_model.dart';
import 'features/search/presentation/screens/search_screen.dart';
import 'shared/offline_banner.dart';

/// Root widget. Installs the dependency graph (composition root) above the
/// [MaterialApp] and configures light/dark theming. It holds no business logic.
///
/// The [database] is opened once in `main` and injected, so tests can supply an
/// in-memory database at the same seam.
class BookshelfApp extends StatelessWidget {
  const BookshelfApp({super.key, required this.database});

  final Database database;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: buildProviders(database),
      // The theme choice lives in a provided ViewModel, so the MaterialApp is
      // built under the provider scope and rebuilds when the mode changes.
      child: Consumer<ThemeViewModel>(
        builder: (context, themeViewModel, _) => MaterialApp(
          title: 'The Bookkeeper',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeViewModel.themeMode,
          // Wrap every route so the offline indicator is evident on any screen.
          builder: (context, child) =>
              OfflineBanner(child: child ?? const SizedBox.shrink()),
          home: const SearchScreen(),
        ),
      ),
    );
  }
}
