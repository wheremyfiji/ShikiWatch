import 'user_image.dart';

class User {
  final int? id;
  final String? nickname;
  final String? avatar;
  final UserImages? image;
  final String? lastOnlineAt;
  final String? url;

  User(
      {required this.id,
      required this.nickname,
      required this.avatar,
      required this.image,
      required this.lastOnlineAt,
      required this.url});

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        nickname = json['nickname'],
        avatar = json['avatar'],
        image =
            json['image'] == null ? null : UserImages.fromJson(json['image']),
        lastOnlineAt = json['last_online_at'],
        url = json['url'];
}
