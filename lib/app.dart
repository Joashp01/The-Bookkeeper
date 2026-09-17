import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'core/di/app_providers.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_view_model.dart';
import 'features/search/presentation/screens/search_screen.dart';
import 'shared/offline_banner.dart';

class BookshelfApp extends StatelessWidget {
  const BookshelfApp({super.key, required this.database});

  final Database database;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: buildProviders(database),
      child: Consumer<ThemeViewModel>(
        builder: (context, themeViewModel, _) => MaterialApp(
          title: 'The Bookkeeper',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeViewModel.themeMode,
          builder: (context, child) =>
              OfflineBanner(child: child ?? const SizedBox.shrink()),
          home: const SearchScreen(),
        ),
      ),
    );
  }
}
