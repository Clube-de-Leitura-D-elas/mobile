import 'package:equatable/equatable.dart';
import 'package:mobile/features/profile/domain/entities/profile_summary_failure.dart';
import 'package:mobile/features/profile/domain/entities/profile_summary_entity.dart';

sealed class ProfileSummaryState extends Equatable {
  const ProfileSummaryState();

  @override
  List<Object?> get props => [];
}

class ProfileSummaryLoading extends ProfileSummaryState {
  const ProfileSummaryLoading();
}

class ProfileSummaryLoaded extends ProfileSummaryState {
  const ProfileSummaryLoaded(this.summary);

  final ProfileSummaryEntity summary;

  @override
  List<Object?> get props => [summary];
}

class ProfileSummaryError extends ProfileSummaryState {
  const ProfileSummaryError(this.failure);

  final ProfileSummaryFailure failure;

  @override
  List<Object?> get props => [failure];
}
