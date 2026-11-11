import 'package:equatable/equatable.dart';

sealed class ProfileFailure extends Equatable {
  const ProfileFailure();

  @override
  List<Object?> get props => [];
}

class ProfileNetworkFailure extends ProfileFailure {
  const ProfileNetworkFailure();
}

class ProfileSessionExpiredFailure extends ProfileFailure {
  const ProfileSessionExpiredFailure();
}

class ProfilePhotoUploadFailure extends ProfileFailure {
  const ProfilePhotoUploadFailure();
}

class ProfilePhotoRejectedFailure extends ProfileFailure {
  const ProfilePhotoRejectedFailure();
}

class ProfilePhotoTooLargeFailure extends ProfileFailure {
  const ProfilePhotoTooLargeFailure();
}
