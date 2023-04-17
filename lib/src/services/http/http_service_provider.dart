import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'dio_service.dart';
import '../../data/repositories/http_service.dart';
import 'cache_storage/cache_storage_provider.dart';

/// Provider that maps an [HttpService] interface to implementation
final httpServiceProvider = Provider<HttpService>((ref) {
  final storageService = ref.watch(cacheStorageServiceProvider);

  return DioHttpService(storageService);
}, name: 'httpServiceProvider');
