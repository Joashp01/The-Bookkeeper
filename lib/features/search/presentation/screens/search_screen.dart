import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/theme_view_model.dart';
import '../../../../shared/responsive_center.dart';
import '../../../favourites/presentation/screens/favourites_screen.dart';
import '../../../favourites/presentation/widgets/favourite_button.dart';
import '../viewmodels/search_state.dart';
import '../viewmodels/search_view_model.dart';
import '../widgets/book_tile.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    const threshold = 300.0;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - threshold) {
      context.read<SearchViewModel>().loadNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SearchViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const _BrandTitle(),
        actions: [
          const _ThemeToggleButton(),
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Favourites',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const FavouritesScreen()),
            ),
          ),
        ],
      ),
      body: ResponsiveCenter(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: TextField(
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Search by title, author or subject',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
                onChanged: context.read<SearchViewModel>().onQueryChanged,
              ),
            ),
            Expanded(
              child: _StateView(
                state: viewModel.state,
                scrollController: _scrollController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.auto_stories_rounded, color: primary, size: 24),
        const SizedBox(width: 8),
        Text(
          'The Bookkeeper',
          style: theme.appBarTheme.titleTextStyle?.copyWith(color: primary),
        ),
      ],
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ThemeViewModel>().themeMode;
    final (icon, label) = switch (mode) {
      ThemeMode.system => (Icons.brightness_auto, 'Theme: follow system'),
      ThemeMode.light => (Icons.light_mode, 'Theme: light'),
      ThemeMode.dark => (Icons.dark_mode, 'Theme: dark'),
    };
    return IconButton(
      icon: Icon(icon),
      tooltip: label,
      onPressed: () => context.read<ThemeViewModel>().cycle(),
    );
  }
}

class _StateView extends StatelessWidget {
  const _StateView({required this.state, required this.scrollController});

  final SearchState state;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      SearchInitial() => const _Centered(
        icon: Icons.search,
        message: 'Search for a book to get started.',
      ),
      SearchTooShort(:final minLength) => _Centered(
        icon: Icons.keyboard,
        message:
            'Keep typing — enter at least $minLength characters to search.',
      ),
      SearchUnsupportedQuery(:final message) => _Centered(
        icon: Icons.search_off,
        message: message,
      ),
      SearchLoading() => const Center(child: CircularProgressIndicator()),
      SearchEmpty() => const _Centered(
        icon: Icons.sentiment_dissatisfied,
        message: 'No results found.',
      ),
      SearchError(:final message) => _ErrorView(message: message),
      SearchResults(:final books, :final isLoadingMore, :final isOffline) =>
        Column(
          children: [
            if (isOffline) const _OfflineBanner(),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: books.length + (isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= books.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final book = books[index];
                  return BookTile(
                    book: book,
                    trailing: FavouriteButton(book: book),
                    onTap: () => openBookDetail(context, book),
                  );
                },
              ),
            ),
          ],
        ),
    };
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: scheme.tertiaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.cloud_off, size: 18, color: scheme.onTertiaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Offline — showing cached results.',
              style: TextStyle(color: scheme.onTertiaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            const Text(
              'Something went wrong.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () => context.read<SearchViewModel>().retry(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
