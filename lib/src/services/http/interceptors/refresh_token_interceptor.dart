import 'dart:developer';

import 'package:dio/dio.dart';

import '../../oauth/oauth_service.dart';
import '../../../utils/app_utils.dart';
import '../../../utils/router.dart';

class RefreshTokenInterceptor extends QueuedInterceptor {
  final Dio dio;

  RefreshTokenInterceptor(this.dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response == null) {
      return handler.next(err);
    }

    if (err.response!.statusCode == 401) {
      final newToken = await OAuthService.instance.refreshToken();

      if (newToken != null) {
        // showSnackBar(
        //   ctx: routerRootCtx!,
        //   msg: 'Токен авторизации успешно обновлен',
        //   dur: const Duration(seconds: 10),
        // );
        final res = await _retry(err.requestOptions, newToken);
        return handler.resolve(res);
      } else {
        showErrorSnackBar(
          ctx: routerRootCtx!,
          msg: 'Ошибка при обновлении токена авторизации',
        );

        // TODO fix this
        log('RefreshTokenInterceptor:: refreshToken() == null');
        //final ctx = router.routerDelegate.navigatorKey.currentContext;
        //GoRouter.of(ctx!).go('/login');
      }
    }

    return handler.next(err);
  }

  Future<Response<dynamic>> _retry(
      RequestOptions requestOptions, String newToken) async {
    requestOptions.headers.addAll({
      'Authorization': 'Bearer $newToken',
    });

    final options = Options(
      method: requestOptions.method,
      contentType: requestOptions.contentType,
      responseType: requestOptions.responseType,
      headers: requestOptions.headers,
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
