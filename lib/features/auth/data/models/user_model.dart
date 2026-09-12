import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel {
  static UserEntity fromSupabase(User user) {
    final metadata = user.userMetadata ?? {};
    final cityZone = metadata['city'] is CityZone
        ? metadata['city'] as CityZone
        : (id: '', name: '', acronym: '');

    return UserEntity(
      name: metadata['full_name'] as String? ?? user.email?.split('@').first ?? '',
      mail: user.email ?? '',
      birthday: metadata['birthday'] as String? ?? '',
      phoneNumber: user.phone ?? metadata['phone'] as String? ?? '',
      instagramUser: metadata['instagram'] as String? ?? '',
      educationDegree: metadata['education_degree'] as String? ?? '',
      jobPosition: metadata['job_position'] as String? ?? '',
      cityZone: cityZone,
    );
  }

  static UserEntity fromProfileMap(Map<String, dynamic> profile) {
    return UserEntity(
      name: profile['name'] as String? ?? '',
      mail: profile['email'] as String? ?? '',
      birthday: profile['birthday'] as String? ?? '',
      phoneNumber: profile['phone_number'] as String? ?? '',
      instagramUser: profile['instagram'] as String? ?? '',
      educationDegree: profile['education_degree'] as String? ?? '',
      jobPosition: profile['job_position'] as String? ?? '',
      cityZone: (id: '', name: '', acronym: ''),
    );
  }
}
