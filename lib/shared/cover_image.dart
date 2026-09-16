import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Displays a book cover from a URL, or a neutral placeholder when the cover is
/// absent (F5: `cover_i` is missing on ~15% of results). Shared by the results
/// list and the detail screen.
///
/// Accessibility: pass [semanticLabel] (e.g. `'Cover of Dune'`) where the cover
/// carries meaning on its own, such as the detail screen. Leave it null where a
/// text label already names the book (e.g. a result tile); the image is then
/// treated as decorative and hidden from screen readers so it isn't announced as
/// a meaningless "image".
class CoverImage extends StatelessWidget {
  const CoverImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.semanticLabel,
  });

  final String? url;
  final double? width;
  final double? height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final image = _image(context);
    final label = semanticLabel;
    if (label == null) {
      return ExcludeSemantics(child: image);
    }
    return Semantics(image: true, label: label, child: image);
  }

  Widget _image(BuildContext context) {
    final url = this.url;
    if (url == null) {
      return _placeholder(context);
    }

    // On web, cached_network_image fetches the bytes over XHR to fill its own
    // cache, which is CORS-restricted and drops these cross-origin covers when
    // the widget rebuilds — e.g. after returning from the detail screen. A plain
    // Image.network renders through the browser's native <img> pipeline, which
    // is not CORS-gated for display and survives navigation. On mobile we keep
    // CachedNetworkImage for its on-disk cache.
    if (kIsWeb) {
      return Image.network(
        url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : _box(
                context,
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
        errorBuilder: (context, _, _) => _placeholder(context),
      );
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
