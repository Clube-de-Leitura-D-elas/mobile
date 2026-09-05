import 'package:mobile/features/auth/domain/entities/user_profile_entity.dart';

class UserProfileModel {
  static UserProfileEntity? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is Map<String, dynamic>) {
      if (json.containsKey('profile')) {
        final profile = json['profile'];
        if (profile == null) return null;
        if (profile is Map<String, dynamic>) return fromMap(profile);
      }
      return fromMap(json);
    }
    return null;
  }

  static UserProfileEntity fromMap(Map<String, dynamic> map) {
    return UserProfileEntity(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      address: (map['address'] as String?) ?? (map['adress'] as String?) ?? '',
      phoneNumber: map['phone_number'] as String? ?? '',
      birthday: map['birthday'] as String? ?? '',
      instagram: map['instagram'] as String? ?? '',
      educationDegree: map['education_degree'] as String? ?? '',
      jobPosition: map['job_position'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      isActive: map['is_Active'] as bool? ?? map['is_active'] as bool? ?? true,
    );
  }
}
