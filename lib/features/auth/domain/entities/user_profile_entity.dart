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
  final DateTime? createdAt;
  final String? photoUrl;

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
    this.createdAt,
    this.photoUrl,
  });

  UserProfileEntity copyWith({String? photoUrl}) {
    return UserProfileEntity(
      id: id,
      name: name,
      email: email,
      address: address,
      phoneNumber: phoneNumber,
      birthday: birthday,
      instagram: instagram,
      educationDegree: educationDegree,
      jobPosition: jobPosition,
      userId: userId,
      isActive: isActive,
      createdAt: createdAt,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

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
    createdAt,
    photoUrl,
  ];
}
