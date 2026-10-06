import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:mobile/core/tools/result.dart';

class PickedPhoto extends Equatable {
  const PickedPhoto({required this.id, required this.bytes, this.contentType});

  /// Gerado na seleção e reenviado nas novas tentativas, para o backend não
  /// duplicar uma foto que já salvou.
  final String id;
  final Uint8List bytes;

  /// `null` quando o formato não é um dos aceitos (jpeg, png, webp, heic).
  final String? contentType;

  @override
  List<Object?> get props => [id, bytes, contentType];
}

sealed class PhotoPickerFailure extends Equatable {
  const PhotoPickerFailure();

  @override
  List<Object?> get props => [];
}

class PhotoAccessDeniedFailure extends PhotoPickerFailure {
  const PhotoAccessDeniedFailure();
}

class PhotoPickerUnknownFailure extends PhotoPickerFailure {
  const PhotoPickerUnknownFailure();
}

abstract class PhotoPicker {
  /// Abre a galeria para escolher até [limit] fotos. Lista vazia quando a
  /// pessoa cancela a seleção.
  Future<Result<List<PickedPhoto>, PhotoPickerFailure>> pickFromGallery({
    required int limit,
  });
}
