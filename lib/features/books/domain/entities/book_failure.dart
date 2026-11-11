import 'package:equatable/equatable.dart';

sealed class BookFailure extends Equatable {
  const BookFailure();

  @override
  List<Object?> get props => [];
}

class BookDetailsLoadFailure extends BookFailure {
  const BookDetailsLoadFailure();
}

class BookNotFoundFailure extends BookFailure {
  const BookNotFoundFailure();
}

class ReadingStatusUpdateFailure extends BookFailure {
  const ReadingStatusUpdateFailure();
}

class BookReviewSaveFailure extends BookFailure {
  const BookReviewSaveFailure();
}
