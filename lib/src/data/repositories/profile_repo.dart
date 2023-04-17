import '../../domain/models/user_friend.dart';
import '../../domain/models/user_profile.dart';

abstract class ProfileRepository {
  const ProfileRepository();

  Future<UserProfile> getUserProfile({
    required String? id,
    String? userToken,
  });

  Future<Iterable<UserFriend>> getUserFriends({required String? id});
}
