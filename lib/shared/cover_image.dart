import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Displays a book cover from a URL, or a neutral placeholder when the cover is
/// absent (F5: `cover_i` is missing on ~15% of results). Shared by the results
/// list and the detail screen.
class CoverImage extends StatelessWidget {
  const CoverImage({
    super.key,
    required this.url,
    this.width,
    this.height,
  });

  final String? url;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    if (url == null) {
      return _placeholder(context);
    }

    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholder: (context, _) => _box(
        context,
        const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (context, _, _) => _placeholder(context),
    );
  }

  Widget _placeholder(BuildContext context) => _box(
        context,
        Icon(
          Icons.menu_book_outlined,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );

  Widget _box(BuildContext context, Widget child) => Container(
        width: width,
        height: height,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: child,
      );
}
