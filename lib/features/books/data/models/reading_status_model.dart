import 'package:mobile/features/books/domain/entities/reading_status.dart';

abstract final class ReadingStatusModel {
  static ReadingStatus? fromJson(dynamic value) {
    return switch (value) {
      'READ' => ReadingStatus.read,
      'WANT_TO_READ' => ReadingStatus.wantToRead,
      _ => null,
    };
  }

  static String? toJson(ReadingStatus? status) {
    return switch (status) {
      ReadingStatus.read => 'READ',
      ReadingStatus.wantToRead => 'WANT_TO_READ',
      null => null,
    };
  }
}
