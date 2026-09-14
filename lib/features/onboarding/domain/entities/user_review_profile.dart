import 'package:equatable/equatable.dart';

class UserReviewProfile extends Equatable {
  final String name;
  final String email;
  final String phone;
  final String birthDate;
  final String city;
  final String region;
  final String job;
  final String levelOfEducation;
  final String otherReadingGroup;
  final String volunteerCoordinator;
  final String bookIndication;
  final String expectations;

  const UserReviewProfile({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.birthDate = '',
    this.city = '',
    this.region = '',
    this.job = '',
    this.levelOfEducation = '',
    this.otherReadingGroup = '',
    this.volunteerCoordinator = '',
    this.bookIndication = '',
    this.expectations = '',
  });

  UserReviewProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? birthDate,
    String? city,
    String? region,
    String? job,
    String? levelOfEducation,
    String? otherReadingGroup,
    String? volunteerCoordinator,
    String? bookIndication,
    String? expectations,
  }) {
    return UserReviewProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      city: city ?? this.city,
      region: region ?? this.region,
      job: job ?? this.job,
      levelOfEducation: levelOfEducation ?? this.levelOfEducation,
      otherReadingGroup: otherReadingGroup ?? this.otherReadingGroup,
      volunteerCoordinator: volunteerCoordinator ?? this.volunteerCoordinator,
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
        city,
        region,
        job,
        levelOfEducation,
        otherReadingGroup,
        volunteerCoordinator,
        bookIndication,
        expectations,
      ];
}
