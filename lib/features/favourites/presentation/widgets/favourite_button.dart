import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../search/domain/models/book.dart';
import '../viewmodels/favourites_view_model.dart';

/// Heart toggle backed by the shared [FavouritesViewModel]. Used on the results
/// list, the detail screen and the favourites screen; they all reflect the same
/// state because they share one view model instance.
class FavouriteButton extends StatelessWidget {
  const FavouriteButton({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final isFavourite =
        context.watch<FavouritesViewModel>().isFavourite(book.key);

    return IconButton(
      icon: Icon(isFavourite ? Icons.favorite : Icons.favorite_border),
      color: isFavourite ? Theme.of(context).colorScheme.primary : null,
      tooltip: isFavourite ? 'Remove from favourites' : 'Add to favourites',
      onPressed: () => context.read<FavouritesViewModel>().toggle(book),
    );
  }
}
