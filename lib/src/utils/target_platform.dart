import 'dart:io';

class TargetP {
  static TargetP instance = TargetP();

  late bool isDesktop;
  late String userAgent;

  static init() {
    instance.isDesktop =
        Platform.isWindows || Platform.isLinux || Platform.isMacOS;

    instance.userAgent = instance.isDesktop
        ? 'Shikimori Flutter Windows App'
        : 'Shikimori Flutter App';
  }
}
