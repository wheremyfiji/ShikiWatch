import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'dio_service.dart';
import '../../data/repositories/http_service.dart';

/// Provider that maps an [HttpService] interface to implementation
final httpServiceProvider = Provider<HttpService>((ref) {
  //final storageService = ref.watch(cacheStorageServiceProvider);

  //return DioHttpService(storageService);
  return DioHttpService();
}, name: 'httpServiceProvider');
