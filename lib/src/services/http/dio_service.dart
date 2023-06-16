import 'dart:developer';

import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:network_logger/network_logger.dart';
import 'package:sentry_dio/sentry_dio.dart';
import 'package:dio/dio.dart';
//import 'package:nirikshak/nirikshak.dart';

//import 'package:native_dio_adapter/native_dio_adapter.dart';
//import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../constants/config.dart';
import '../../data/repositories/http_service.dart';
import '../../utils/target_platform.dart';

import 'interceptors/request_interceptor.dart';
import 'interceptors/refresh_token_interceptor.dart';

// const _defaultConnectTimeout = 30000;
// const _defaultReceiveTimeout = 30000;

//Nirikshak nirikshak = Nirikshak();

class DioHttpService implements HttpService {
  /// Creates new instance of [DioHttpService]
  DioHttpService() {
    dio = Dio(baseOptions);

    // if (Platform.isIOS || Platform.isMacOS || Platform.isAndroid) {
    //   dio.httpClientAdapter = NativeAdapter();
    // }

    // if (kDebugMode) {
    //   dio.interceptors.add(LogInterceptor());
    // }
    // if (kDebugMode) {
    //   dio.interceptors.add(PrettyDioLogger(
    //     requestHeader: true,
    //     requestBody: true,
    //     responseBody: false,
    //     responseHeader: true,
    //     error: true,
    //     compact: true,
    //     maxWidth: 100,
    //     logPrint: (object) {
    //       log(object.toString(), name: 'PrettyDioLogger');
    //     },
    //   ));
    // }
    dio.interceptors.add(RetryInterceptor(
      dio: dio,
      logPrint: log,
      retries: 1,
      retryDelays: const [
        Duration(seconds: 4),
      ],
    ));

    dio.interceptors.add(RefreshTokenInterceptor(dio));
    dio.interceptors.add(RequestInterceptors(dio));

    // if (kDebugMode) {
    //   dio.interceptors.add(PrettyDioLogger(
    //     requestHeader: true,
    //     requestBody: true,
    //     responseBody: false,
    //     responseHeader: true,
    //     error: true,
    //     compact: true,
    //     maxWidth: 100,
    //     logPrint: (object) {
    //       log(object.toString(), name: 'Dio');
    //     },
    //   ));
    // }
    dio.interceptors.add(DioNetworkLogger());
    //dio.interceptors.add(nirikshak.getDioInterceptor());
    dio.addSentry();
  }

  //final CacheStorageRepo storageService;
  late final Dio dio;

  BaseOptions get baseOptions => BaseOptions(
        baseUrl: baseUrl,
        headers: headers,
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 30),
        //connectTimeout: _defaultConnectTimeout,
        //receiveTimeout: _defaultReceiveTimeout,
      );

  @override
  String get baseUrl => AppConfig.baseUrl;

  @override
  Map<String, String> headers = {
    'User-Agent': TargetP.instance.userAgent,
  };

  /// GET method
  @override
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    dio.options.extra[AppConfig.dioNeedToCacheKey] = false;
    dio.options.extra[AppConfig.dioCacheForceRefreshKey] = true;
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
    dio.options.extra[AppConfig.dioNeedToCacheKey] = false;
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
    dio.options.extra[AppConfig.dioNeedToCacheKey] = false;
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
    dio.options.extra[AppConfig.dioNeedToCacheKey] = false;
    return await dio
        .delete(endpoint, options: options)
        .then((value) => value.statusCode?.clamp(200, 299) == value.statusCode)
        .onError((_, __) => false);
  }
}

// class CustomInterceptors implements Interceptor {
//   CustomInterceptors();

//   @override
//   void onError(DioError err, ErrorInterceptorHandler handler) {
//     final code = err.response?.statusMessage;
//     log('ERROR[$code] => PATH: ${err.requestOptions.path}');
//     return handler.next(err);
//   }

//   @override
//   void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
//     log('REQUEST[${options.method}] => PATH: ${options.path}');
//     return handler.next(options);
//   }

//   /// Method that intercepts Dio response
//   @override
//   void onResponse(
//     Response<dynamic> response,
//     ResponseInterceptorHandler handler,
//   ) {
//     final code = response.statusCode;
//     log('::onResponse -> code: $code');
//     return handler.next(response);
//     log('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
//     return handler.next(response);
//   }
// }

// class CustomInterceptors2 extends Interceptor {
//   @override
//   void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
//     print('REQUEST[${options.method}] => PATH: ${options.path}');
//     super.onRequest(options, handler);
//   }

//   @override
//   void onResponse(Response response, ResponseInterceptorHandler handler) {
//     print(
//         'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
//     super.onResponse(response, handler);
//   }

//   @override
//   void onError(DioError err, ErrorInterceptorHandler handler) {
//     print(
//         'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
//     super.onError(err, handler);
//   }
// }
