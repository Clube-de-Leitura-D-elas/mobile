import 'package:equatable/equatable.dart';

class UserProfileEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String address;
  final String phoneNumber;
  final String birthday;
  final String instagram;
  final String educationDegree;
  final String jobPosition;
  final String userId;
  final bool isActive;

  const UserProfileEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.address,
    required this.phoneNumber,
    required this.birthday,
    required this.instagram,
    required this.educationDegree,
    required this.jobPosition,
    required this.userId,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        address,
        phoneNumber,
        birthday,
        instagram,
        educationDegree,
        jobPosition,
        userId,
        isActive,
      ];
}
