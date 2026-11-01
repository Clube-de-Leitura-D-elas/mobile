import 'dart:typed_data';

import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/profile/domain/entities/profile_failure.dart';

abstract class ProfileRepository {
  Future<Result<String, ProfileFailure>> setProfilePhoto({
    required Uint8List bytes,
    required String contentType,
  });
}
