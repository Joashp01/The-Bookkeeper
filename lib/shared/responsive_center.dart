import 'package:flutter/material.dart';

/// Constrains its child to a readable maximum width and centres it horizontally.
///
/// On phones the child fills the screen; on wide web/desktop windows the content
/// sits in a centred column instead of stretching edge-to-edge. [child] keeps
/// full height (so scroll views still work), only the width is bounded.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({super.key, required this.child, this.maxWidth = 720});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
