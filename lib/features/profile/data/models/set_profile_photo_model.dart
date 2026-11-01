class SetProfilePhotoModel {
  const SetProfilePhotoModel({required this.photoUrl});

  final String photoUrl;

  static String? photoUrlFromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    final url = json['photo_url'];
    if (url is! String || url.isEmpty) return null;
    return url;
  }
}
