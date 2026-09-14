import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/cover_image.dart';
import '../../../favourites/presentation/widgets/favourite_button.dart';
import '../../domain/models/book.dart';
import '../../domain/models/book_detail.dart';
import '../../domain/repositories/book_detail_repository.dart';
import '../viewmodels/detail_state.dart';
import '../viewmodels/detail_view_model.dart';

/// Pushes the detail screen for [book], creating a scoped [DetailViewModel] from
/// the repository already registered in the widget tree.
Future<void> openBookDetail(BuildContext context, Book book) {
  final repository = context.read<BookDetailRepository>();
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ChangeNotifierProvider<DetailViewModel>(
        create: (_) => DetailViewModel(repository: repository, book: book),
        child: const DetailScreen(),
      ),
    ),
  );
}

/// The detail screen (F2). Loads on first build and renders the work's cover,
/// title, author(s), year, subjects and description.
class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  void initState() {
    super.initState();
    // Defer to after the first frame: load() notifies listeners synchronously,
    // which must not happen during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DetailViewModel>().load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DetailViewModel>();
    final state = viewModel.state;

    final title = switch (state) {
      DetailLoaded(:final detail) => detail.title,
      _ => viewModel.book.title,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [FavouriteButton(book: viewModel.book)],
      ),
      body: switch (state) {
        DetailLoading() => const Center(child: CircularProgressIndicator()),
        DetailError(:final message) => _ErrorView(message: message),
        DetailLoaded(:final detail) => _DetailBody(detail: detail),
      },
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.detail});

  final BookDetail detail;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CoverImage(url: detail.coverUrl, width: 160, height: 240),
          ),
        ),
        const SizedBox(height: 20),
        Text(detail.title, style: textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(detail.authorDisplay, style: textTheme.titleMedium),
        const SizedBox(height: 4),
        Text('First published: ${detail.yearDisplay}', style: textTheme.bodyMedium),
        if (detail.subjects.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Subjects', style: textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final subject in detail.subjects.take(12))
                Chip(label: Text(subject)),
            ],
          ),
        ],
        const SizedBox(height: 16),
        Text('Description', style: textTheme.titleSmall),
        const SizedBox(height: 8),
        Text(detail.descriptionDisplay, style: textTheme.bodyLarge),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            const Text(
              'Could not load this book.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () => context.read<DetailViewModel>().load(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
