import 'dart:convert';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:dio/dio.dart';

import '../../../constants/config.dart';
import '../../../data/repositories/cache_storage_repo.dart';
import '../../../domain/models/cached_response.dart';

class CacheInterceptor implements Interceptor {
  CacheInterceptor(this.cacheStorageService);

  final CacheStorageRepo cacheStorageService;

  @visibleForTesting
  String createStorageKey(
    String method,
    String baseUrl,
    String path, [
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
  ]) {
    var storageKey = '${method.toUpperCase()}:${baseUrl + path}/';
    if (queryParameters.isNotEmpty) {
      storageKey += '?';
      queryParameters.forEach((key, dynamic value) {
        storageKey += '$key=$value&';
      });
    }
    log('(createStorageKey) key = $storageKey', name: 'CacheInterceptor');
    return storageKey;
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    final storageKey = createStorageKey(
      err.requestOptions.method,
      err.requestOptions.baseUrl,
      err.requestOptions.path,
      err.requestOptions.queryParameters,
    );
    if (cacheStorageService.has(storageKey)) {
      final cachedResponse = _getCachedResponse(storageKey);
      if (cachedResponse != null) {
        log('(onError) Get response from cache', name: 'CacheInterceptor');
        final response = cachedResponse.buildResponse(err.requestOptions);
        return handler.resolve(response);
      }
    }
    return handler.next(err);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final storageKey = createStorageKey(
      options.method,
      options.baseUrl,
      options.path,
      options.queryParameters,
    );

    if (options.extra[AppConfig.dioNeedToCacheKey] == false) {
      //log('(onRequest) Does not need caching', name: 'CacheInterceptor');
      if (cacheStorageService.has(storageKey)) {
        // log('(onRequest) Delete responce from caching',
        //     name: 'CacheInterceptor');
        cacheStorageService.remove(storageKey);
      }
      return handler.next(options);
    }

    if (options.extra[AppConfig.dioCacheForceRefreshKey] == true) {
      //log('(onRequest) Cache Force Refresh', name: 'CacheInterceptor');
      if (cacheStorageService.has(storageKey)) {
        // log('(onRequest) Delete responce from caching',
        //     name: 'CacheInterceptor');
        cacheStorageService.remove(storageKey);
      }
      return handler.next(options);
    }

    if (cacheStorageService.has(storageKey)) {
      final cachedResponse = _getCachedResponse(storageKey);
      if (cachedResponse != null) {
        //log('(onRequest) Get response from cache', name: 'CacheInterceptor');
        final response = cachedResponse.buildResponse(options);
        return handler.resolve(response);
      }
    }

    return handler.next(options);

    // if (options.extra[AppConfig.dioCacheForceRefreshKey] == true) {
    //   log('(onRequest) Does not need caching');
    //   return handler.next(options);
    // }
    // final storageKey = createStorageKey(
    //   options.method,
    //   options.baseUrl,
    //   options.path,
    //   options.queryParameters,
    // );
    // if (cacheStorageService.has(storageKey)) {
    //   final cachedResponse = _getCachedResponse(storageKey);
    //   if (cachedResponse != null) {
    //     log('(onRequest) Get response from cache');
    //     final response = cachedResponse.buildResponse(options);
    //     return handler.resolve(response);
    //   }
    // }
    // return handler.next(options);
  }

  /// Method that intercepts Dio response
  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (response.requestOptions.extra[AppConfig.dioNeedToCacheKey] == false) {
      //log('(onResponse) Does not need caching', name: 'CacheInterceptor');
      return handler.next(response);
    }

    final storageKey = createStorageKey(
      response.requestOptions.method,
      response.requestOptions.baseUrl,
      response.requestOptions.path,
      response.requestOptions.queryParameters,
    );

    if (response.requestOptions.extra[AppConfig.dioCacheForceRefreshKey] ==
        true) {
      //log('(onResponse) Cache Force Refresh', name: 'CacheInterceptor');
      return handler.next(response);
    }

    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final cachedResponse = CachedResponse(
        data: response.data,
        headers: Headers.fromMap(response.headers.map),
        age: DateTime.now(),
        statusCode: response.statusCode!,
      );
      //log('Save response to cache', name: 'CacheInterceptor');
      cacheStorageService.set(storageKey, cachedResponse.toJson());
    }
    return handler.next(response);
  }

  CachedResponse? _getCachedResponse(String storageKey) {
    final dynamic rawCachedResponse = cacheStorageService.get(storageKey);
    try {
      final cachedResponse = CachedResponse.fromJson(
        json.decode(json.encode(rawCachedResponse)) as Map<String, dynamic>,
      );
      if (cachedResponse.isValid) {
        return cachedResponse;
      } else {
        //log('Cache is outdated, deleting it...', name: 'CacheInterceptor');
        cacheStorageService.remove(storageKey);
        return null;
      }
    } catch (e) {
      //log('Error retrieving response from cache', name: 'CacheInterceptor');
      log('e: $e');
      return null;
    }
  }
}
