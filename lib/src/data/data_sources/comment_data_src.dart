import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/models/shiki_comment.dart';
import '../../services/http/http_service_provider.dart';
import '../repositories/comment_repo.dart';
import '../repositories/http_service.dart';

final commentDataSourceProvider = Provider<CommentDataSource>(
    (ref) => CommentDataSource(ref.read(httpServiceProvider)),
    name: 'commentDataSourceProvider');

class CommentDataSource implements CommentRepository {
  final HttpService dio;

  CommentDataSource(this.dio);

  @override
  Future<Iterable<ShikiComment>> getComments({
    required int commentableId,
    required String commentableType,
    required int page,
    required int limit,
    required String userToken,
    required CancelToken cancelToken,
    int? desc,
  }) async {
    final response = await dio.get(
      'comments',
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
        'commentable_id': commentableId.toString(),
        'commentable_type': commentableType,
        if (desc != null) 'desc': desc.toString(),
      },
      cancelToken: cancelToken,
      options: Options(
        headers: {
          'Authorization': 'Bearer $userToken',
        },
      ),
    );

    return [for (final e in response) ShikiComment.fromJson(e)];
  }
}
