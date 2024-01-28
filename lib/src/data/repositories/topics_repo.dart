import 'package:dio/dio.dart';

import '../../domain/enums/topic_linked_type.dart';
import '../../domain/models/shiki_topic.dart';

abstract class TopicsRepository {
  const TopicsRepository();

  Future<List<ShikiTopic>> getTopics({
    int? page,
    int? limit,
    String? forum,
    int? linkedId,
    LinkedType? linkedType,
    String? type,
    CancelToken? cancelToken,
  });
}
