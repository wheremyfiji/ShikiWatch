import 'dart:io';

class TargetP {
  TargetP._();

  static final TargetP _instance = TargetP._();

  static TargetP get instance => _instance;

  late bool isDesktop;
  late String userAgent;
  late String appCachePath;

  static init(Directory appCacheDir) {
    _instance.appCachePath = appCacheDir.path;

    _instance.isDesktop =
        Platform.isWindows || Platform.isLinux || Platform.isMacOS;

    _instance.userAgent = _instance.isDesktop
        ? 'Shikimori Flutter Windows App'
        : 'Shikimori Flutter App';
  }
}
