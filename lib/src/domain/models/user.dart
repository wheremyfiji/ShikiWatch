import 'user_image.dart';

class User {
  int? id;
  String? nickname;
  String? avatar;
  UserImages? image;
  String? lastOnlineAt;
  String? url;

  User(
      {this.id,
      this.nickname,
      this.avatar,
      this.image,
      this.lastOnlineAt,
      this.url});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nickname = json['nickname'];
    avatar = json['avatar'];
    image = json['image'] != null ? UserImages.fromJson(json['image']) : null;
    lastOnlineAt = json['last_online_at'];
    url = json['url'];
  }
}
