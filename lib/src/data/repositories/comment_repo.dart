import 'package:dio/dio.dart';

import '../../domain/models/shiki_comment.dart';

abstract class CommentRepository {
  const CommentRepository();

  Future<Iterable<ShikiComment>> getComments({
    required int commentableId,
    required String commentableType,
    required int page,
    required int limit,
    int? desc,
    required String userToken,
    required CancelToken cancelToken,
  });
}
