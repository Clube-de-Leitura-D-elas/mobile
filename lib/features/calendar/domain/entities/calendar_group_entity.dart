import 'package:equatable/equatable.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_membership_status.dart';

class CalendarGroupEntity extends Equatable {
  final String id;
  final int number;
  final String? cityState;
  final String? photoUrl;
  final int participantCount;
  final CalendarMembershipStatus membershipStatus;

  const CalendarGroupEntity({
    required this.id,
    required this.number,
    this.cityState,
    required this.participantCount,
    required this.membershipStatus,
    this.photoUrl,
  });

  bool get isMember => membershipStatus == CalendarMembershipStatus.member;

  @override
  List<Object?> get props => [
    id,
    number,
    cityState,
    photoUrl,
    participantCount,
    membershipStatus,
  ];
}
