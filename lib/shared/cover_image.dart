import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

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
