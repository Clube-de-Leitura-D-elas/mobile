import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/profile/data/models/set_profile_photo_model.dart';
import 'package:mobile/features/profile/domain/entities/profile_failure.dart';
import 'package:mobile/features/profile/domain/repository/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({required this.supabaseService});

  final SupabaseService supabaseService;

  static const _rejectedCodes = {'400', '404', '422'};

  @override
  Future<Result<String, ProfileFailure>> setProfilePhoto({
    required Uint8List bytes,
    required String contentType,
  }) async {
    final result = await supabaseService.invokeFunction<String>(
      functionName: 'set-profile-photo',
      body: {
        'contentType': contentType,
        'encoded': await compute(base64Encode, bytes),
      },
      decoder: (dynamic json) {
        final url = SetProfilePhotoModel.photoUrlFromJson(json);
        if (url == null) {
          throw const FormatException('missing photo_url');
        }
        return url;
      },
    );

    switch (result) {
      case Failure(:final failure):
        return Failure(_mapFailure(failure.code));
      case Success(:final data):
        final photoUrl = data.data;
        if (photoUrl == null || photoUrl.isEmpty) {
          return const Failure(ProfilePhotoUploadFailure());
        }
        return Success(photoUrl);
    }
  }

  ProfileFailure _mapFailure(String? code) {
    if (code == '413') return const ProfilePhotoTooLargeFailure();
    if (_rejectedCodes.contains(code)) {
      return const ProfilePhotoRejectedFailure();
    }
    return const ProfilePhotoUploadFailure();
  }
}
