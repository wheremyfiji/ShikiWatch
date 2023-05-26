import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/models/manga_ranobe.dart';
import '../../services/http/http_service_provider.dart';
import '../repositories/http_service.dart';
import '../repositories/ranobe_repo.dart';

final ranobeDataSourceProvider = Provider<RanobeDataSource>(
    (ref) => RanobeDataSource(ref.read(httpServiceProvider)),
    name: 'ranobeDataSourceProvider');

class RanobeDataSource implements RanobeRepository {
  final HttpService dio;

  RanobeDataSource(this.dio);

  @override
  Future<MangaRanobe> getRanobe({
    required int? id,
    required CancelToken cancelToken,
    String? token,
    bool forceRefresh = false,
    bool needToCache = false,
  }) async {
    final response = await dio.get(
      'ranobe/$id',
      cancelToken: cancelToken,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return MangaRanobe.fromJson(response);
  }
}
