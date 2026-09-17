import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/responsive_center.dart';
import '../../../search/presentation/screens/detail_screen.dart';
import '../../../search/presentation/widgets/book_tile.dart';
import '../viewmodels/favourites_view_model.dart';
import '../widgets/favourite_button.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FavouritesViewModel>();
    final favourites = viewModel.favourites;

    return Scaffold(
      appBar: AppBar(title: const Text('Favourites')),
      body: ResponsiveCenter(
        child: Builder(
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
      ),
    );
  }
}

class _EmptyFavourites extends StatelessWidget {
  const _EmptyFavourites();

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
              child: Icon(
                Icons.favorite_border,
                size: 40,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No favourites yet.',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap the heart on a book to save it here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
