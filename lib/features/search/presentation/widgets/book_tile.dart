import 'package:flutter/material.dart';

import '../../../../shared/cover_image.dart';
import '../../domain/models/book.dart';

/// A single search result row: cover, title, author and first publication year.
///
/// Reads only the [Book]'s display getters, so all "missing field" decisions are
/// made in the model, not here.
class BookTile extends StatelessWidget {
  const BookTile({
    super.key,
    required this.book,
    this.onTap,
  });

  final Book book;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: SizedBox(
        width: 40,
        height: 56,
        child: CoverImage(url: book.coverUrl, width: 40, height: 56),
      ),
      title: Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${book.authorDisplay} · ${book.yearDisplay}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
