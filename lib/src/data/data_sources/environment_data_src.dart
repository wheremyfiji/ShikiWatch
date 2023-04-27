import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../repositories/environment_repo.dart';

class EnvironmentDataSource implements EnvironmentRepo {
  EnvironmentDataSource({
    required this.packageInfo,
    this.androidInfo,
    this.windowsInfo,
  });

  @override
  final PackageInfo packageInfo;

  @override
  final AndroidDeviceInfo? androidInfo;

  @override
  final WindowsDeviceInfo? windowsInfo;

  @override
  int? get sdkVersion => androidInfo?.version.sdkInt;
}
