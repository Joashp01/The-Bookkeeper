import 'package:bookshelf/core/error/failure.dart';
import 'package:bookshelf/core/error/result.dart';
import 'package:bookshelf/features/search/domain/models/book.dart';
import 'package:bookshelf/features/search/domain/models/book_detail.dart';
import 'package:bookshelf/features/search/domain/repositories/book_detail_repository.dart';
import 'package:bookshelf/features/search/presentation/viewmodels/detail_state.dart';
import 'package:bookshelf/features/search/presentation/viewmodels/detail_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDetailRepo implements BookDetailRepository {
  _FakeDetailRepo(this.result);

  final Result<BookDetail> result;
  int callCount = 0;

  @override
  Future<Result<BookDetail>> getDetail(Book book) async {
    callCount++;
    return result;
  }
}

const _book = Book(
  key: '/works/OL1W',
  title: 'Dune',
  authorNames: ['Frank Herbert'],
);

const _detail = BookDetail(
  workId: 'OL1W',
  title: 'Dune',
  authorNames: ['Frank Herbert'],
  subjects: ['Science Fiction'],
  description: 'A desert epic.',
);

void main() {
  test('starts in the loading state', () {
    final vm = DetailViewModel(
      repository: _FakeDetailRepo(const Success(_detail)),
      book: _book,
    );
    expect(vm.state, isA<DetailLoading>());
  });

  test('load() transitions to DetailLoaded on success', () async {
    final vm = DetailViewModel(
      repository: _FakeDetailRepo(const Success(_detail)),
      book: _book,
    );

    await vm.load();

    expect(vm.state, isA<DetailLoaded>());
    expect((vm.state as DetailLoaded).detail, _detail);
  });

  test('load() transitions to DetailError on failure', () async {
    final vm = DetailViewModel(
      repository: _FakeDetailRepo(
        const FailureResult(ServerFailure('boom', statusCode: 500)),
      ),
      book: _book,
    );

    await vm.load();

    expect(vm.state, isA<DetailError>());
    expect((vm.state as DetailError).message, 'boom');
  });
}
