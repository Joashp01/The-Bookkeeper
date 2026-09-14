import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'core/di/app_providers.dart';
import 'core/theme/app_theme.dart';
import 'features/search/presentation/screens/search_screen.dart';

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
      child: MaterialApp(
        title: 'The Bookkeeper',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const SearchScreen(),
      ),
    );
  }
}
