import 'package:equatable/equatable.dart';
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
  final String message;

  /// Falso quando o grupo não existe: tentar de novo não adianta.
  final bool canRetry;

  const GroupDetailsError(this.message, {this.canRetry = true});

  @override
  List<Object?> get props => [message, canRetry];
}
