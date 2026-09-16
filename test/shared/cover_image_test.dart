import 'package:bookshelf/shared/cover_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

Iterable<Semantics> _semanticsOf(WidgetTester tester) => tester.widgetList<Semantics>(
      find.descendant(
        of: find.byType(CoverImage),
        matching: find.byType(Semantics),
      ),
    );

void main() {
  testWidgets('exposes a labelled image node to screen readers',
      (tester) async {
    await tester.pumpWidget(
      _wrap(const CoverImage(url: null, semanticLabel: 'Cover of Dune')),
    );

    expect(
      _semanticsOf(tester).any(
        (s) => s.properties.image == true && s.properties.label == 'Cover of Dune',
      ),
      isTrue,
    );
  });

  testWidgets('is hidden from screen readers when unlabelled (decorative)',
      (tester) async {
    await tester.pumpWidget(_wrap(const CoverImage(url: null)));

    // The decorative cover excludes itself from the semantics tree, so it never
    // contributes an image node for assistive tech to announce.
    expect(
      find.descendant(
        of: find.byType(CoverImage),
        matching: find.byType(ExcludeSemantics),
      ),
      findsWidgets,
    );
    expect(
      _semanticsOf(tester).any((s) => s.properties.image == true),
      isFalse,
    );
  });
}
