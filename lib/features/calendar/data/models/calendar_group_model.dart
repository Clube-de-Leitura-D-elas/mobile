import 'package:mobile/features/calendar/domain/entities/calendar_group_entity.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_membership_status.dart';

class CalendarGroupModel {
  final String id;
  final int number;
  final String? cityState;
  final String? photoUrl;
  final int participantCount;
  final CalendarMembershipStatus membershipStatus;

  const CalendarGroupModel({
    required this.id,
    required this.number,
    this.cityState,
    required this.participantCount,
    required this.membershipStatus,
    this.photoUrl,
  });

  factory CalendarGroupModel.fromJson(Map<String, dynamic> json) {
    return CalendarGroupModel(
      id: json['id'] as String,
      number: (json['number'] as num).toInt(),
      cityState: json['city_state'] as String?,
      photoUrl: json['photo_url'] as String?,
      participantCount: (json['participant_count'] as num).toInt(),
      membershipStatus: _parseMembership(json['membership_status']),
    );
  }

  static CalendarMembershipStatus _parseMembership(dynamic value) {
    return switch (value) {
      'MEMBER' => CalendarMembershipStatus.member,
      'REQUESTED' => CalendarMembershipStatus.requested,
      'REJECTED' => CalendarMembershipStatus.rejected,
      'PENDING' => CalendarMembershipStatus.pending,
      _ => CalendarMembershipStatus.none,
    };
  }

  CalendarGroupEntity toDomain() {
    return CalendarGroupEntity(
      id: id,
      number: number,
      cityState: cityState,
      photoUrl: photoUrl,
      participantCount: participantCount,
      membershipStatus: membershipStatus,
    );
  }
}
