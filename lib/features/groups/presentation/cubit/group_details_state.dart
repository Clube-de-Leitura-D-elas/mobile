import 'package:equatable/equatable.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/group_details_entity.dart';

sealed class GroupDetailsState extends Equatable {
  const GroupDetailsState();

  @override
  List<Object?> get props => [];
}

class GroupDetailsLoading extends GroupDetailsState {
  const GroupDetailsLoading();
}

class GroupDetailsLoaded extends GroupDetailsState {
  final GroupDetailsEntity group;

  const GroupDetailsLoaded(this.group);

  @override
  List<Object?> get props => [group];
}

class GroupDetailsError extends GroupDetailsState {
  const GroupDetailsError(this.failure);

  final GroupFailure failure;

  @override
  List<Object?> get props => [failure];
}
