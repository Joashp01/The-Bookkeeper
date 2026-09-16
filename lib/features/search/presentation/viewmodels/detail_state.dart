import 'package:equatable/equatable.dart';

import '../../domain/models/book_detail.dart';

/// State for the detail screen: loading, loaded or error.
sealed class DetailState extends Equatable {
  const DetailState();

  @override
  List<Object?> get props => [];
}

class DetailLoading extends DetailState {
  const DetailLoading();
}

class DetailLoaded extends DetailState {
  const DetailLoaded(this.detail);

  final BookDetail detail;

  @override
  List<Object?> get props => [detail];
}

/// The detail load failed; [message] is friendly, user-safe copy to display.
class DetailError extends DetailState {
  const DetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
