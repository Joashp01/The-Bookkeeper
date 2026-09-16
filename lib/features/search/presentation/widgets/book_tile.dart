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
    this.trailing,
  });

  final Book book;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      // The cover is decorative here — the title/author text already names the
      // book — so CoverImage is left unlabelled and hidden from screen readers.
      leading: SizedBox(
        width: 40,
        height: 56,
        child: CoverImage(url: book.coverUrl, width: 40, height: 56),
      ),
      title: Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      // ListTile merges title + subtitle into one tappable node. The visible
      // "·"-separated line reads awkwardly aloud, so we hand the screen reader a
      // natural-language label and hide the decorative visual text from it.
      subtitle: Semantics(
        label: '${book.authorDisplay}, published ${book.yearDisplay}',
        child: ExcludeSemantics(
          child: Text(
            '${book.authorDisplay} · ${book.yearDisplay}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      trailing: trailing,
    );
  }
}
