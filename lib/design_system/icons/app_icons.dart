import 'package:equatable/equatable.dart';

class AppIconAsset extends Equatable {
  const AppIconAsset._(this.assetPath);

  final String assetPath;

  @override
  List<Object?> get props => [assetPath];
}

abstract final class AppIcons {
  static const book = AppIconAsset._('assets/icons/si/book.si');
  static const calendar = AppIconAsset._('assets/icons/si/calendar.si');
  static const camera = AppIconAsset._('assets/icons/si/camera.si');
  static const clock = AppIconAsset._('assets/icons/si/clock.si');
  static const group = AppIconAsset._('assets/icons/si/group.si');
  static const home = AppIconAsset._('assets/icons/si/home.si');
  static const host = AppIconAsset._('assets/icons/si/host.si');
  static const location = AppIconAsset._('assets/icons/si/location.si');
  static const plus = AppIconAsset._('assets/icons/si/plus.si');
  static const search = AppIconAsset._('assets/icons/si/search.si');
  static const settings = AppIconAsset._('assets/icons/si/settings.si');
  static const user = AppIconAsset._('assets/icons/si/user.si');

  static const List<AppIconAsset> all = [
    book,
    calendar,
    camera,
    clock,
    group,
    home,
    host,
    location,
    plus,
    search,
    settings,
    user,
  ];
}
