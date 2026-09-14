import 'package:bookshelf/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app boots to the search screen', (tester) async {
    await tester.pumpWidget(const BookshelfApp());

    expect(find.text('The Bookkeeper'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
