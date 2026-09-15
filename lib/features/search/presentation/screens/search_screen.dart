import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../favourites/presentation/screens/favourites_screen.dart';
import '../../../favourites/presentation/widgets/favourite_button.dart';
import '../viewmodels/search_state.dart';
import '../viewmodels/search_view_model.dart';
import '../widgets/book_tile.dart';
import 'detail_screen.dart';

/// The search screen (F1). Owns the scroll controller (a UI concern) and wires
/// input and scroll events to the [SearchViewModel]; it contains no business
/// logic of its own.
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
        title: const Text('The Bookkeeper'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Favourites',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const FavouritesScreen(),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Search books',
                hintText: 'Title, author, subject…',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: context.read<SearchViewModel>().onQueryChanged,
            ),
          ),
          Expanded(child: _StateView(state: viewModel.state, scrollController: _scrollController)),
        ],
      ),
    );
  }
}

/// Renders the current [SearchState]. Each of the four states is visibly
/// distinct.
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

/// Clear indicator shown above cached results when the device is offline (F4).
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
        ],
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
