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
      onPressed: () => _toggle(context),
    );
  }

  /// Toggles the favourite and, if persistence failed, tells the user rather
  /// than letting the change silently disappear. The messenger is captured
  /// before the await so we don't touch a possibly-unmounted context after it.
  Future<void> _toggle(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final error = await context.read<FavouritesViewModel>().toggle(book);
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    }
  }
}
