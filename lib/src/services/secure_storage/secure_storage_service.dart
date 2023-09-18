import 'package:flutter/foundation.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService extends SecureStorageValues {
  static SecureStorageService instance = SecureStorageService();

  static const _keyToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _userId = 'user_id';
  static const _userNickname = 'user_nickname';
  static const _userProfileImage = 'user_profile_image';

  late FlutterSecureStorage storage;

  // AndroidOptions getAndroidOptions() => const AndroidOptions(
  //       encryptedSharedPreferences: true,
  //     );

  static Future<void> initialize() async {
    instance.storage = const FlutterSecureStorage(
        wOptions: WindowsOptions(useBackwardCompatibility: true)
        //aOptions: instance.getAndroidOptions(),
        );

    await instance.read();
    //instance.debug();
  }

  void debug() {
    debugPrint('SecureStorage: token = $token');
    debugPrint('SecureStorage: refreshToken = $refreshToken');
    debugPrint('SecureStorage: userId = $userId');
    debugPrint('SecureStorage: userProfileImage = $userProfileImage');
  }

  Future<void> read() async {
    //logDebug('SecureStorage: read values');
    token = await readToken() ?? '';
    refreshToken = await readRefreshToken() ?? '';
    userId = await readUserId() ?? '';
    userProfileImage = await readUserImage() ?? '';
    userNickname = await readUserNickname() ?? '';
  }

  Future<String?> readUserNickname() async {
    return await storage.read(key: _userNickname);
  }

  Future<void> writeUserNickname(String string) async {
    return await storage.write(key: _userNickname, value: string);
  }

  Future<String?> readUserId() async {
    return await storage.read(key: _userId);
  }

  Future<void> writeUserId(String string) async {
    return await storage.write(key: _userId, value: string);
  }

  Future<String?> readUserImage() async {
    return await storage.read(key: _userProfileImage);
  }

  Future<void> writeUserImage(String string) async {
    return await storage.write(key: _userProfileImage, value: string);
  }

  Future<String?> readToken() async {
    return await storage.read(key: _keyToken);
  }

  Future<String?> readRefreshToken() async {
    return await storage.read(key: _keyRefreshToken);
  }

  Future<void> writeToken(String token) async {
    return await storage.write(key: _keyToken, value: token);
  }

  Future<void> writeRefreshToken(String refreshToken) async {
    return await storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  Future<void> delete(String key) async {
    return await storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    return await storage.deleteAll();
  }
}

class SecureStorageValues {
  late String token;
  late String refreshToken;
  late String userId;
  late String userProfileImage;
  late String userNickname;
}
