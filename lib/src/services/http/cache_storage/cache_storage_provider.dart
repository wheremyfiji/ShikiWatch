import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../data/repositories/cache_storage_repo.dart';
import 'cache_storage_service.dart';

final cacheStorageServiceProvider = Provider<CacheStorageRepo>(
    (ref) => CacheStorageImpl(),
    name: 'cacheStorageServiceProvider');
