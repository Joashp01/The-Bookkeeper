import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../search/presentation/screens/detail_screen.dart';
import '../../../search/presentation/widgets/book_tile.dart';
import '../viewmodels/favourites_view_model.dart';
import '../widgets/favourite_button.dart';

/// Dedicated screen listing all favourited books. Reads the shared
/// [FavouritesViewModel]; favourites are fully readable offline because they
/// come from local storage.
class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FavouritesViewModel>();
    final favourites = viewModel.favourites;

    return Scaffold(
      appBar: AppBar(title: const Text('Favourites')),
      body: Builder(
        builder: (context) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (favourites.isEmpty) {
            return const _EmptyFavourites();
          }
          return ListView.builder(
            itemCount: favourites.length,
            itemBuilder: (context, index) {
              final book = favourites[index];
              return BookTile(
                book: book,
                trailing: FavouriteButton(book: book),
                onTap: () => openBookDetail(context, book),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyFavourites extends StatelessWidget {
  const _EmptyFavourites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.favorite_border,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          const Text('No favourites yet.'),
        ],
      ),
    );
  }
}
