import 'package:equatable/equatable.dart';

typedef CityZone = ({String id, String name, String acronym});

class UserEntity extends Equatable {
  final String name;
  final String mail;
  final String birthday;
  final String phoneNumber;
  final String instagramUser;
  final String educationDegree;
  final String jobPosition;
  final CityZone cityZone;

  const UserEntity({
    required this.name,
    required this.mail,
    required this.birthday,
    required this.phoneNumber,
    required this.instagramUser,
    required this.educationDegree,
    required this.jobPosition,
    required this.cityZone,
  });

  UserEntity copyWith({
    String? name,
    String? mail,
    String? birthday,
    String? phoneNumber,
    String? instagramUser,
    String? educationDegree,
    String? jobPosition,
    CityZone? cityZone,
  }) {
    return UserEntity(
      name: name ?? this.name,
      mail: mail ?? this.mail,
      birthday: birthday ?? this.birthday,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      instagramUser: instagramUser ?? this.instagramUser,
      educationDegree: educationDegree ?? this.educationDegree,
      jobPosition: jobPosition ?? this.jobPosition,
      cityZone: cityZone ?? this.cityZone,
    );
  }

  @override
  List<Object?> get props => [
        name,
        mail,
        birthday,
        phoneNumber,
        instagramUser,
        educationDegree,
        jobPosition,
        cityZone,
      ];
}
