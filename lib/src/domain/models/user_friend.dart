import 'user_image.dart';

class UserFriend {
  int? id;
  String? nickname;
  String? avatar;
  UserImages? image;
  String? lastOnlineAt;
  String? url;

  UserFriend(
      {this.id,
      this.nickname,
      this.avatar,
      this.image,
      this.lastOnlineAt,
      this.url});

  UserFriend.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nickname = json['nickname'];
    avatar = json['avatar'];
    image = json['image'] != null ? UserImages.fromJson(json['image']) : null;
    lastOnlineAt = json['last_online_at'];
    url = json['url'];
  }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = <String, dynamic>{};
  //   data['id'] = id;
  //   data['nickname'] = nickname;
  //   data['avatar'] = avatar;
  //   if (image != null) {
  //     data['image'] = image!.toJson();
  //   }
  //   data['last_online_at'] = lastOnlineAt;
  //   data['url'] = url;
  //   return data;
  // }
}
