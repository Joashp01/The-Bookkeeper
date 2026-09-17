import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../search/domain/models/book.dart';
import '../viewmodels/favourites_view_model.dart';

class FavouriteButton extends StatelessWidget {
  const FavouriteButton({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final isFavourite = context.watch<FavouritesViewModel>().isFavourite(
      book.key,
    );

    return IconButton(
      icon: Icon(isFavourite ? Icons.favorite : Icons.favorite_border),
      color: isFavourite ? Theme.of(context).colorScheme.primary : null,
      tooltip: isFavourite ? 'Remove from favourites' : 'Add to favourites',
      onPressed: () => _toggle(context),
    );
  }

  Future<void> _toggle(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final error = await context.read<FavouritesViewModel>().toggle(book);
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    }
  }
}
