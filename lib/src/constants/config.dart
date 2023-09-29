import 'dart:ffi';

class AppConfig {
  AppConfig._();

  static const int databaseVersion = 1;
  static const String databaseVersionKey = "isarVersionKey";

  static const String baseUrl = 'https://shikimori.one/api/';
  static const String staticUrl = 'https://shikimori.one';
}

String get kAppArch {
  switch (Abi.current()) {
    case Abi.androidX64:
      return 'x86_64';
    case Abi.androidArm64:
      return 'arm64-v8a';
    case Abi.androidIA32:
    case Abi.androidArm:
      return 'armeabi-v7a';
    default:
      return Abi.current().toString();
  }
}
