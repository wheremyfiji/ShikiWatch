import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/models/user_friend.dart';
import '../repositories/profile_repo.dart';
import '../repositories/http_service.dart';
import '../../domain/models/user_profile.dart';
import '../../services/http/http_service_provider.dart';

final profileDataSourceProvider = Provider<ProfileDataSource>(
    (ref) => ProfileDataSource(ref.read(httpServiceProvider)),
    name: 'animeDataSourceProvider');

class ProfileDataSource implements ProfileRepository {
  final HttpService dio;
  ProfileDataSource(this.dio);

  @override
  Future<UserProfile> getUserProfile({
    required String? id,
    String? userToken,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.get(
      'users/$id',
      cancelToken: cancelToken,
      options: Options(
        headers: {
          'Authorization': 'Bearer $userToken',
        },
      ),
    );

    return UserProfile.fromJson(response);
  }

  @override
  Future<Iterable<UserFriend>> getUserFriends({
    required String? id,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.get(
      'users/$id/friends',
      cancelToken: cancelToken,
    );

    return [for (final e in response) UserFriend.fromJson(e)];
  }
}
