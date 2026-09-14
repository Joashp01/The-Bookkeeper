import 'package:flutter/foundation.dart';

import '../../domain/models/book.dart';
import '../../domain/repositories/book_detail_repository.dart';
import 'detail_state.dart';

/// Presentation-layer state holder for the detail screen.
///
/// Loads the full [BookDetail] for the tapped [book] via the repository. The
/// book is retained so the app bar can show its title while the detail loads.
class DetailViewModel extends ChangeNotifier {
  // Named parameters cannot be private, so `this._repository` is impossible;
  // assigning in the initializer list is the idiomatic alternative.
  DetailViewModel({
    required BookDetailRepository repository,
    required this.book,
  }) : _repository = repository; // ignore: prefer_initializing_formals

  final BookDetailRepository _repository;
  final Book book;

  DetailState _state = const DetailLoading();
  DetailState get state => _state;

  Future<void> load() async {
    _setState(const DetailLoading());
    final result = await _repository.getDetail(book);
    result.when(
      success: (detail) => _setState(DetailLoaded(detail)),
      failure: (failure) => _setState(DetailError(failure.message)),
    );
  }

  void _setState(DetailState newState) {
    _state = newState;
    notifyListeners();
  }
}
