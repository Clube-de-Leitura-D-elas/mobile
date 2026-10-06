import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/media/image_content_type.dart';
import 'package:mobile/core/media/photo_picker.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/core/tools/uuid.dart';

class ImagePickerPhotoPicker implements PhotoPicker {
  ImagePickerPhotoPicker(this._imagePicker);

  static const _imageQuality = 80;
  static const _maxDimension = 1920.0;

  final ImagePicker _imagePicker;

  @override
  Future<Result<List<PickedPhoto>, PhotoPickerFailure>> pickFromGallery({
    required int limit,
  }) async {
    try {
      final files = await _pickFiles(limit);
      final photos = await Future.wait(files.take(limit).map(_toPickedPhoto));
      return Success(photos);
    } on PlatformException catch (error) {
      return Failure(
        error.code.endsWith('access_denied')
            ? const PhotoAccessDeniedFailure()
            : const PhotoPickerUnknownFailure(),
      );
    } catch (_) {
      return const Failure(PhotoPickerUnknownFailure());
    }
  }

  // `pickMultiImage` exige limit >= 2.
  Future<List<XFile>> _pickFiles(int limit) async {
    if (limit < 2) {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: _imageQuality,
        maxWidth: _maxDimension,
        maxHeight: _maxDimension,
      );
      return file == null ? const [] : [file];
    }

    return _imagePicker.pickMultiImage(
      imageQuality: _imageQuality,
      maxWidth: _maxDimension,
      maxHeight: _maxDimension,
      limit: limit,
    );
  }

  Future<PickedPhoto> _toPickedPhoto(XFile file) async {
    final bytes = await file.readAsBytes();
    return PickedPhoto(
      id: generateUuidV4(),
      bytes: bytes,
      contentType: detectImageContentType(bytes),
    );
  }
}
