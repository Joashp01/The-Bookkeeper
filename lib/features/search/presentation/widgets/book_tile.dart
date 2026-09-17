import 'package:flutter/material.dart';

import '../../../../shared/cover_image.dart';
import '../../domain/models/book.dart';

/// A single search result row: cover, title, author and first publication year,
/// presented as a tappable card.
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The cover is decorative here — the title/author text already
              // names the book — so CoverImage is left unlabelled and hidden
              // from screen readers.
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 48,
                  height: 68,
                  child: CoverImage(url: book.coverUrl, width: 48, height: 68),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    // ListTile-style merged line, but hand the screen reader a
                    // natural-language label and hide the decorative "·" text.
                    Semantics(
                      label:
                          '${book.authorDisplay}, published ${book.yearDisplay}',
                      child: ExcludeSemantics(
                        child: Text(
                          book.authorDisplay,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _YearPill(year: book.yearDisplay),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

/// Small muted pill showing the first publication year.
class _YearPill extends StatelessWidget {
  const _YearPill({required this.year});

  final String year;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          year,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}
