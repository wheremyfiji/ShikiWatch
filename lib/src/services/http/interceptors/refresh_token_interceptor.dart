import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../utils/target_platform.dart';
import '../../oauth/oauth_service.dart';

class RefreshTokenInterceptor extends Interceptor {
  final Dio dio;

  RefreshTokenInterceptor(this.dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response == null) {
      return handler.next(err);
    }
    if (err.response!.statusCode == 401) {
      //log('RefreshTokenInterceptor:: statusCode == 401');
      var res = await refreshToken();
      if (res != null) {
        await _retry(err.requestOptions, res);
        return handler.resolve(await _retry(err.requestOptions, res));
      } else {
        // TODO fix this
        log('RefreshTokenInterceptor:: refreshToken() == null');
        //final ctx = router.routerDelegate.navigatorKey.currentContext;
        //GoRouter.of(ctx!).go('/login');
      }
    }
    return handler.next(err);
  }

  Future<String?> refreshToken() async {
    //log('RefreshTokenInterceptor:: refreshToken');

    final token = await OAuthService.instance.refreshToken();

    return token;
  }

  Future<Response<dynamic>> _retry(
      RequestOptions requestOptions, String newToken) async {
    log('RefreshTokenInterceptor:: _retry');

    final options = Options(
      method: requestOptions.method,
      responseType: requestOptions.responseType,
      headers: {
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
