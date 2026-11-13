import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:mobile/features/profile/data/models/set_profile_photo_model.dart';
import 'package:mobile/features/profile/domain/entities/profile_failure.dart';
import 'package:mobile/features/profile/domain/entities/profile_summary_entity.dart';
import 'package:mobile/features/profile/domain/repository/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required this.supabaseService,
    required this.remoteDataSource,
  });

  final SupabaseService supabaseService;
  final ProfileRemoteDataSource remoteDataSource;

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
        return Failure(_mapFailure(failure));
      case Success(:final data):
        final photoUrl = data.data;
        if (photoUrl == null || photoUrl.isEmpty) {
          return const Failure(ProfilePhotoUploadFailure());
        }
        return Success(photoUrl);
    }
  }

  @override
  Future<Result<ProfileSummaryEntity, ProfileFailure>>
  getProfileSummary() async {
    final result = await remoteDataSource.getMyProfileSummary();

    switch (result) {
      case Failure(:final failure):
        debugPrint('[ProfileSummary] ${failure.message} (${failure.code})');
        return Failure(
          _connectionFailure(failure) ?? const ProfileSummaryLoadFailure(),
        );
      case Success(:final data):
        if (data == null) return const Failure(ProfileSummaryLoadFailure());
        return Success(data.toDomain());
    }
  }

  /// Rede e sessão valem para qualquer chamada do perfil.
  ProfileFailure? _connectionFailure(SupabaseFailure failure) {
    return switch (failure.kind) {
      SupabaseFailureKind.network => const ProfileNetworkFailure(),
      SupabaseFailureKind.unauthorized => const ProfileSessionExpiredFailure(),
      _ => null,
    };
  }

  ProfileFailure _mapFailure(SupabaseFailure failure) {
    final connection = _connectionFailure(failure);
    if (connection != null) return connection;
    final code = failure.code;
    if (code == '413') return const ProfilePhotoTooLargeFailure();
    if (_rejectedCodes.contains(code)) {
      return const ProfilePhotoRejectedFailure();
    }
    return const ProfilePhotoUploadFailure();
  }
}
