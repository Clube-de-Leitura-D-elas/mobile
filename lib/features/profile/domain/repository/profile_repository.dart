import 'dart:typed_data';

import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/profile/domain/entities/profile_failure.dart';
import 'package:mobile/features/profile/domain/entities/profile_summary_entity.dart';
import 'package:mobile/features/profile/domain/entities/profile_summary_failure.dart';

abstract class ProfileRepository {
  Future<Result<String, ProfileFailure>> setProfilePhoto({
    required Uint8List bytes,
    required String contentType,
  });

  Future<Result<ProfileSummaryEntity, ProfileSummaryFailure>>
  getProfileSummary();
}
