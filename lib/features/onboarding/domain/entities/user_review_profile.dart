import 'package:equatable/equatable.dart';

class UserReviewProfile extends Equatable {
  final String name;
  final String email;
  final String phone;
  final String birthDate;
  final String? cityId;
  final String cityName;
  final String? zoneId;
  final String zoneName;
  final String job;
  final String levelOfEducation;
  final bool? hasOtherReadingGroup;
  final bool? wantsToCoordinate;
  final String bookIndication;
  final String expectations;

  const UserReviewProfile({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.birthDate = '',
    this.cityId,
    this.cityName = '',
    this.zoneId,
    this.zoneName = '',
    this.job = '',
    this.levelOfEducation = '',
    this.hasOtherReadingGroup,
    this.wantsToCoordinate,
    this.bookIndication = '',
    this.expectations = '',
  });

  UserReviewProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? birthDate,
    String? cityId,
    String? cityName,
    String? zoneId,
    String? zoneName,
    bool clearCity = false,
    bool clearZone = false,
    String? job,
    String? levelOfEducation,
    bool? hasOtherReadingGroup,
    bool? wantsToCoordinate,
    String? bookIndication,
    String? expectations,
  }) {
    return UserReviewProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      cityId: clearCity ? null : (cityId ?? this.cityId),
      cityName: clearCity ? '' : (cityName ?? this.cityName),
      zoneId: clearZone ? null : (zoneId ?? this.zoneId),
      zoneName: clearZone ? '' : (zoneName ?? this.zoneName),
      job: job ?? this.job,
      levelOfEducation: levelOfEducation ?? this.levelOfEducation,
      hasOtherReadingGroup: hasOtherReadingGroup ?? this.hasOtherReadingGroup,
      wantsToCoordinate: wantsToCoordinate ?? this.wantsToCoordinate,
      bookIndication: bookIndication ?? this.bookIndication,
      expectations: expectations ?? this.expectations,
    );
  }

  @override
  List<Object?> get props => [
    name,
    email,
    phone,
    birthDate,
    cityId,
    cityName,
    zoneId,
    zoneName,
    job,
    levelOfEducation,
    hasOtherReadingGroup,
    wantsToCoordinate,
    bookIndication,
    expectations,
  ];
}
