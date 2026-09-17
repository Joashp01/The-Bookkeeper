import 'package:flutter/foundation.dart';

import '../../../../core/error/failure_messages.dart';
import '../../domain/models/book.dart';
import '../../domain/repositories/book_detail_repository.dart';
import 'detail_state.dart';

class DetailViewModel extends ChangeNotifier {
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
      failure: (failure) => _setState(DetailError(messageForFailure(failure))),
    );
  }

  void _setState(DetailState newState) {
    _state = newState;
    notifyListeners();
  }
}
