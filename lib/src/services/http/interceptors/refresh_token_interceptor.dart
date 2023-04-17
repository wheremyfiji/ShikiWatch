import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/router.dart';
import '../../../utils/target_platform.dart';
import '../../oauth/oauth_service.dart';

class RefreshTokenInterceptor extends Interceptor {
  final Dio dio;

  RefreshTokenInterceptor(this.dio);

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response == null) {
      return handler.next(err);
    }
    if (err.response!.statusCode == 401) {
      log('RefreshTokenInterceptor:: statusCode == 401');
      var res = await refreshToken();
      if (res != null) {
        await _retry(err.requestOptions, res);
        return handler.resolve(await _retry(err.requestOptions, res));
      } else {
        log('RefreshTokenInterceptor:: refreshToken() == null');
        final ctx = router.routerDelegate.navigatorKey.currentContext;
        GoRouter.of(ctx!).go('/login');
      }
    }
    //super.onError(err, handler);
    return handler.next(err);
  }

  /// Api to get new token from refresh token
  ///
  Future<String?> refreshToken() async {
    log('RefreshTokenInterceptor:: refreshToken');

    ///call your refesh token api here
    final token = await OAuthService.instance.refreshToken();

    return token;

    // if (await OAuthService.instance.refreshToken()) {
    //   return true;
    // }
    // return null;
  }

  /// For retrying request with new token
  ///
  Future<Response<dynamic>> _retry(
      RequestOptions requestOptions, String newToken) async {
    log('RefreshTokenInterceptor:: _retry');
    // final options = Options(
    //   method: requestOptions.method,
    //   headers: requestOptions.headers,
    // );

    // final options = requestOptions.copyWith(
    //   headers: {
    //     'User-Agent': 'Shikimori Flutter App',
    //     'Authorization': 'Bearer $newToken',
    //   },
    // );

    final options = Options(
      method: requestOptions.method,
      responseType: requestOptions.responseType,
      headers: {
        //'User-Agent': 'Shikimori Flutter App',
        //'User-Agent': 'Shikimori Flutter Windows App',
        'User-Agent': TargetP.instance.userAgent,
        'Authorization': 'Bearer $newToken',
      },
    );

    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      cancelToken: requestOptions.cancelToken,
      onSendProgress: requestOptions.onSendProgress,
      onReceiveProgress: requestOptions.onReceiveProgress,
      options: options,
    );
  }
}
