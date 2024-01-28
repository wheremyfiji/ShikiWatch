import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dio/dio.dart';

import '../../domain/enums/topic_linked_type.dart';
import '../../domain/models/shiki_topic.dart';

import '../repositories/http_service.dart';
import '../repositories/topics_repo.dart';

import '../../services/http/http_service_provider.dart';

final topicsDataSourceProvider = Provider<TopicsDataSource>(
    (ref) => TopicsDataSource(ref.read(httpServiceProvider)),
    name: 'animeDataSourceProvider');

class TopicsDataSource implements TopicsRepository {
  TopicsDataSource(this.client);

  final HttpService client;

  @override
  Future<List<ShikiTopic>> getTopics({
    int? page,
    int? limit,
    String? forum,
    int? linkedId,
    LinkedType? linkedType,
    String? type,
    CancelToken? cancelToken,
  }) async {
    final response = await client.get(
      'topics',
      queryParameters: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
        if (forum != null) 'forum': forum,
        if (linkedId != null) 'linked_id': linkedId.toString(),
        if (linkedType != null) 'linked_type': linkedType.value,
        if (type != null) 'type': type,
      },
      cancelToken: cancelToken,
    );

    return <ShikiTopic>[
      for (final e in response) ShikiTopic.fromJson(e),
    ];
  }
}
