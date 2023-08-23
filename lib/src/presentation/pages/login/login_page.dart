import 'package:flutter/material.dart';

import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../services/oauth/oauth_service.dart';
import '../../../../secret.dart';

import '../../../utils/router.dart';
import 'disclaimer_dialog.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool isLoading = false;

  void goToHome() {
    ref.read(routerNotifierProvider.notifier).userLogin = true;

    GoRouter.of(context).go('/library');
  }

  void auth() async {
    setState(() {
      isLoading = true;
    });

    const callbackUrlScheme = 'shikidev';
    const url =
        'https://shikimori.me/oauth/authorize?client_id=$kShikiClientId&redirect_uri=shikidev%3A%2F%2Foauth%2Fshikimori&response_type=code&scope=user_rates';

    try {
      final result = await FlutterWebAuth.authenticate(
          url: url,
          callbackUrlScheme: callbackUrlScheme,
          preferEphemeral: true);

      // TODO Add Null Check
      final code = Uri.parse(result).queryParameters['code'];

      bool getTokenResult = await OAuthService.instance.getToken(code!);

      if (getTokenResult) {
        goToHome();
      } else {
        setState(() {
          isLoading = false;
        });
        _showSnackbar('Ошибка авторизации', 4);
      }
    } on Exception catch (e, s) {
      final expString = e.toString();
      setState(() {
        isLoading = false;
      });

      if (expString.contains('CANCELED')) {
        _showSnackbar('Пользователь отменил вход', 4);
      } else {
        await Sentry.captureException(
          e,
          stackTrace: s,
          withScope: (scope) {
            scope.level = SentryLevel.fatal;
          },
        );
        _showSnackbar('Ошибка авторизации', 4);
      }
    }
  }

  void _showSnackbar(String msg, int dur) {
    final snackBar = SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      dismissDirection: DismissDirection.horizontal,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 48),
      duration: Duration(seconds: dur),
      showCloseIcon: true,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 64),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Привет!',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Для использования приложения\nнеобходимо войти в аккаунт Shikimori',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            if (isLoading) ...[
              const Card(
                margin: EdgeInsets.all(0),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text('Получение токена..'),
                    ],
                  ),
                ),
              ),
            ],
            if (!isLoading) ...[
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: () async {
                    bool? dialogValue = await showDialog<bool>(
                      context: context,
                      builder: (context) => const DisclaimerDialog(),
                    );
                    if (dialogValue ?? false) {
                      auth();
                    }
                  },
                  child: const Row(
                    children: [
                      Icon(
                        Icons.login_outlined,
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Text('Войти'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 48,
                child: FilledButton.tonal(
                  onPressed: () {
                    context.push('/login/settings');
                  },
                  child: const Row(
                    children: [
                      Icon(
                        Icons.settings_outlined,
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Text('Настройки'),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
