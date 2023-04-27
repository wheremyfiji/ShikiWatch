import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

abstract class EnvironmentRepo {
  PackageInfo get packageInfo;
  AndroidDeviceInfo? get androidInfo;
  WindowsDeviceInfo? get windowsInfo;
  int? get sdkVersion;
}
