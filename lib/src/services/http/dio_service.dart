import 'dart:developer';

import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:network_logger/network_logger.dart';
import 'package:sentry_dio/sentry_dio.dart';
import 'package:dio/dio.dart';

import '../../constants/config.dart';
import '../../data/repositories/http_service.dart';
import '../../utils/app_utils.dart';

import 'interceptors/request_interceptor.dart';
import 'interceptors/refresh_token_interceptor.dart';

class DioHttpService implements HttpService {
  /// Creates new instance of [DioHttpService]
  DioHttpService() {
    dio = Dio(baseOptions);

    dio.interceptors.add(RetryInterceptor(
      dio: dio,
      logPrint: log,
      retries: 1,
      retryDelays: const [
        Duration(seconds: 4),
      ],
    ));

    //dio.interceptors.add(RequestLimitInterceptor());
    dio.interceptors.add(RefreshTokenInterceptor(dio));
    dio.interceptors.add(RequestInterceptors(dio));

    // if (kDebugMode) {
    //   dio.interceptors.add(PrettyDioLogger(
    //     requestHeader: true,
    //     requestBody: true,
    //     responseHeader: false,
    //     responseBody: false,
    //     error: true,
    //     compact: true,
    //     maxWidth: 100,
    //     logPrint: (object) {
    //       log(object.toString(), name: 'DioLogger');
    //     },
    //   ));
    // }

    dio.interceptors.add(DioNetworkLogger());
    dio.addSentry();
  }

  //final CacheStorageRepo storageService;
  late final Dio dio;

  BaseOptions get baseOptions => BaseOptions(
        baseUrl: baseUrl,
        headers: headers,
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 30),
        //contentType: 'application/json; charset=utf-8',
        responseType: ResponseType.json,
        followRedirects: false,
      );

  @override
  String get baseUrl => AppConfig.baseUrl;

  @override
  Map<String, String> headers = {
    //'Content-Type': 'application/json; charset=utf-8',
    'User-Agent': AppUtils.instance.userAgent,
  };

  /// GET method
  @override
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      var response = await dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// POST method
  @override
  Future<dynamic> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      var response = await dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data;
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }

  /// path method
  @override
  Future<dynamic> path(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      var response = await dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data;
    } on FormatException catch (_) {
      throw const FormatException("Unable to update the data");
    } catch (e) {
      rethrow;
    }
  }

  /// delete method
  @override
  Future<bool> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await dio
        .delete(endpoint, options: options)
        .then((value) => value.statusCode?.clamp(200, 299) == value.statusCode)
        .onError((_, __) => false);
  }
}
