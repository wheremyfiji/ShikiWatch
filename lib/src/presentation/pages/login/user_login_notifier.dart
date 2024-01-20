import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../services/oauth/oauth_service.dart';
import '../../../../secret.dart';

final userLoginProvider =
    StateNotifierProvider.autoDispose<UserLoginNotifier, AsyncValue<void>>(
  (ref) {
    return UserLoginNotifier();
  },
  name: 'userLoginProvider',
);

class UserLoginNotifier extends StateNotifier<AsyncValue> {
  UserLoginNotifier() : super(const AsyncValue.data(null));

  Future<void> logIn({
    required Function() onFinally,
  }) async {
    try {
      state = const AsyncValue.loading();

      // await Future.delayed(const Duration(seconds: 2));
      // state = AsyncValue.error('Пользователь отменил вход', StackTrace.current);
      // state = const AsyncValue.data(null);
      // return;

      final result = await FlutterWebAuth.authenticate(
        url: url,
        callbackUrlScheme: callbackUrlScheme,
        preferEphemeral: true,
      );

      final code = Uri.parse(result).queryParameters['code'];

      if (code == null) {
        state = AsyncValue.error('Ошибка при авторизации', StackTrace.current);

        return;
      }

      bool getTokenResult = await OAuthService.instance.getToken(code);

      if (getTokenResult) {
        onFinally();
        state = const AsyncValue.data(null);
      } else {
        state = AsyncValue.error(
          'Ошибка при получении токена',
          StackTrace.current,
        );
      }
    } catch (error, s) {
      if (error.toString().contains('CANCELED')) {
        state = AsyncValue.error('Пользователь отменил вход', s);
      } else {
        await Sentry.captureException(
          error,
          stackTrace: s,
          withScope: (scope) {
            scope.level = SentryLevel.fatal;
          },
        );

        state = AsyncValue.error(error, s);
      }
    }
  }

  static const String callbackUrlScheme = 'shikidev';
  static const String url =
      'https://shikimori.one/oauth/authorize?client_id=$kShikiClientId&redirect_uri=shikidev%3A%2F%2Foauth%2Fshikimori&response_type=code&scope=user_rates';
}
