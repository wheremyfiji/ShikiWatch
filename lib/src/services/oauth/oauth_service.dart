import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';
import 'dart:convert' as convert;

import '../../../secret.dart';
import '../../utils/target_platform.dart';
import '../../utils/utils.dart';
import '../secure_storage/secure_storage_service.dart';

class OAuthService {
  static OAuthService instance = OAuthService();

  Map<String, String> headers = {
    'User-Agent': TargetP.instance.isDesktop
        ? 'Shikimori Flutter Windows App'
        : 'Shikimori Flutter App',
  };

  Future<bool> getToken(String authCode) async {
    http.Response tokenRequestResponse = await http.post(
      getUrl(Uri.parse('https://shikimori.me'), '/oauth/token', {
        'grant_type': 'authorization_code',
        'client_id':
            TargetP.instance.isDesktop ? kShikiClientIdDesktop : kShikiClientId,
        'client_secret': TargetP.instance.isDesktop
            ? kShikiClientSecretDesktop
            : kShikiClientSecret,
        'code': authCode,
        'redirect_uri': TargetP.instance.isDesktop
            ? 'urn:ietf:wg:oauth:2.0:oob'
            : 'shikidev://oauth/shikimori',
      }),
      headers: headers,
    );

    //logDebug('[Auth login] ${tokenRequestResponse.statusCode}');

    if (tokenRequestResponse.statusCode == 200) {
      //logDebug('[Auth login] Get Access Token');
      final data =
          convert.jsonDecode(tokenRequestResponse.body) as Map<String, dynamic>;

      await SecureStorageService.instance.writeToken(data['access_token']!);
      await SecureStorageService.instance
          .writeRefreshToken(data['refresh_token']!);

      SecureStorageService.instance.token = data['access_token'];
      SecureStorageService.instance.refreshToken = data['refresh_token'];

      if (await getUserInfo(data['access_token'])) {
        //logDebug('[Auth login] new request token = ${data['access_token']}');
        //logDebug('[Auth login] new refresh token = ${data['refresh_token']}');
        return true;
      }

      return true;
    }

    return false;
  }

  Future<String?> refreshToken() async {
    http.Response tokenRefreshResponse = await http.post(
      getUrl(
        Uri.parse('https://shikimori.me'),
        '/oauth/token',
        {
          'grant_type': 'refresh_token',
          'client_id': TargetP.instance.isDesktop
              ? kShikiClientIdDesktop
              : kShikiClientId,
          'client_secret': TargetP.instance.isDesktop
              ? kShikiClientSecretDesktop
              : kShikiClientSecret,
          'refresh_token': SecureStorageService.instance.refreshToken,
        },
      ),
      headers: headers,
    );

    //logDebug('[Auth refreshToken] ${tokenRefreshResponse.statusCode}');

    if (tokenRefreshResponse.statusCode == 200) {
      final data =
          convert.jsonDecode(tokenRefreshResponse.body) as Map<String, dynamic>;

      await SecureStorageService.instance.writeToken(data['access_token']!);
      await SecureStorageService.instance
          .writeRefreshToken(data['refresh_token']!);

      SecureStorageService.instance.token = data['access_token'];
      SecureStorageService.instance.refreshToken = data['refresh_token'];

      //logDebug('[Auth refreshToken] updated token = ${data['access_token']}');
      //logDebug(
      //    '[Auth refreshToken] updated refresh token = ${data['refresh_token']}');

      return data['access_token'];
    }
    return null;
    // else {
    //   throw Exception(
    //       '[Auth refreshToken] Error requesting new token with refresh token');
    // }
  }

  Future<bool> getUserInfo(String token) async {
    final Uri userUrl = Uri.https('shikimori.me', 'api/users/whoami');

    final Map<String, String> headers = {
      'User-Agent': TargetP.instance.isDesktop
          ? 'Shikimori Flutter Windows App'
          : 'Shikimori Flutter App',
      'Authorization': 'Bearer $token',
    };

    final http.Response userGetResponse =
        await http.get(userUrl, headers: headers);

    if (userGetResponse.statusCode == 200) {
      final json = convert.jsonDecode(
        convert.utf8.decode(userGetResponse.bodyBytes),
      );

      WhoIAm data = WhoIAm.fromJson(json);

      await SecureStorageService.instance.writeUserId(data.id.toString());
      await SecureStorageService.instance
          .writeUserImage(data.image!.x160 ?? '');

      SecureStorageService.instance.userId = data.id.toString();
      SecureStorageService.instance.userProfileImage = data.image!.x160 ?? '';

      AppMetrica.reportEvent('[NORMAL] User log-in)');

      return true;
    } else {
      var statusCode = userGetResponse.statusCode;
      logError('Failed to get USER response');
      throw Exception('Failed to get USER response. Status code = $statusCode');
    }
  }
}

class WhoIAm {
  int? id;
  String? nickname;
  String? avatar;
  Image? image;
  String? lastOnlineAt;
  String? url;
  String? sex;
  String? website;
  String? locale;

  WhoIAm(
      {this.id,
      this.nickname,
      this.avatar,
      this.image,
      this.lastOnlineAt,
      this.url,
      this.sex,
      this.website,
      this.locale});

  WhoIAm.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nickname = json['nickname'];
    avatar = json['avatar'];
    image = json['image'] != null ? Image.fromJson(json['image']) : null;
    lastOnlineAt = json['last_online_at'];
    url = json['url'];
    sex = json['sex'];
    website = json['website'];
    locale = json['locale'];
  }
}

class Image {
  String? x160;
  String? x148;
  String? x80;
  String? x64;
  String? x48;
  String? x32;
  String? x16;

  Image(
      {this.x160, this.x148, this.x80, this.x64, this.x48, this.x32, this.x16});

  Image.fromJson(Map<String, dynamic> json) {
    x160 = json['x160'];
    x148 = json['x148'];
    x80 = json['x80'];
    x64 = json['x64'];
    x48 = json['x48'];
    x32 = json['x32'];
    x16 = json['x16'];
  }
}
