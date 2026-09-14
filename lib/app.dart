import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/app_providers.dart';
import 'core/theme/app_theme.dart';
import 'shared/placeholder_home.dart';

/// Root widget. Installs the dependency graph (composition root) above the
/// [MaterialApp] and configures light/dark theming. It holds no business logic.
class BookshelfApp extends StatelessWidget {
  const BookshelfApp({super.key});

  @override
  Widget build(BuildContext context) {
    final materialApp = MaterialApp(
      title: 'The Bookkeeper',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const PlaceholderHome(),
    );

    // `MultiProvider` requires a non-empty list; until feature branches register
    // dependencies we render the app directly.
    if (providers.isEmpty) return materialApp;
    return MultiProvider(providers: providers, child: materialApp);
  }
}
