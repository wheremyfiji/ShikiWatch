import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shikidev/src/utils/extensions/buildcontext.dart';
import 'package:tinycolor2/tinycolor2.dart';
import '../../../../secret.dart';
import '../../../services/secure_storage/secure_storage_service.dart';
import '../../../services/oauth/oauth_service.dart';

import 'disclaimer_dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool showSplash = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (SecureStorageService.instance.token != '') {
      Sentry.configureScope(
        (scope) => scope.setUser(
          SentryUser(
            id: SecureStorageService.instance.userId,
          ),
        ),
      );
      SchedulerBinding.instance.addPostFrameCallback((_) {
        goToHome();
      });
    } else {
      setState(() {
        showSplash = false;
      });
    }
  }

  void goToHome() {
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
        // _showSnackbar('Unhandled exception', 4);
        _showSnackbar('Ошибка авторизации', 4);
        //_status = 'Got error: $expString';
      }
    }
  }

  void _showSnackbar(String msg, int dur) {
    final snackBar = SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      dismissDirection: DismissDirection.horizontal,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 48),
      //padding: const EdgeInsets.all(8),
      duration: Duration(seconds: dur),
      showCloseIcon: true,
      //backgroundColor: Theme.of(context).colorScheme.onSurface,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    if (showSplash) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // begin: Alignment.topLeft,
          // end: Alignment.bottomRight,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.8],
          colors: [
            //Colors.purple,
            //Colors.orange,
            MediaQuery.of(context).platformBrightness == Brightness.dark
                ? context.theme.colorScheme.onTertiary
                : context.theme.colorScheme.tertiary.lighten(20),
            MediaQuery.of(context).platformBrightness == Brightness.dark
                ? context.theme.colorScheme.onPrimary
                : context.theme.colorScheme.primary.lighten(20),
            //context.theme.colorScheme.background,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // appBar: AppBar(
        //   backgroundColor: Colors.transparent,
        //   title: const Text('ShikiWatch'),
        // ),
        extendBody: true,
        body:
            // SizedBox(
            //   width: MediaQuery.of(context).size.width,
            //   height: MediaQuery.of(context).size.height,
            //   child: LavaAnimation(
            //     color: Theme.of(context).colorScheme.primaryContainer,
            //     child:
            Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Center(
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Привет!',
                        //textAlign: TextAlign.center,
                        // style: TextStyle(
                        //   fontSize: 32,
                        //   color: Theme.of(context).colorScheme.primary,
                        // ),
                        style: Theme.of(context).textTheme.headlineLarge,
                        // style: Theme.of(context)
                        //     .textTheme
                        //     .headlineLarge
                        //     ?.copyWith(
                        //         color: Theme.of(context).colorScheme.primary),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Для использования приложения\nнеобходимо войти в аккаунт Shikimori',
                        //textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),

                      const SizedBox(height: 48), //48

                      if (isLoading) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onPrimary,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Column(
                            children: const [
                              Center(child: CircularProgressIndicator()),
                              SizedBox(height: 16),
                              Center(child: Text('Получение токена')),
                            ],
                          ),
                        ),
                      ],
                      if (!isLoading) ...[
                        ElevatedButton(
                          onPressed: () async {
                            bool? dialogValue = await showDialog<bool>(
                              context: context,
                              builder: (context) => const DisclaimerDialog(),
                            );
                            if (dialogValue ?? false) {
                              auth();
                            }
                          },
                          child: Row(
                            children: const [
                              Icon(
                                Icons.login_outlined,
                                //size: 32,
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              Text('Войти'),
                            ],
                          ),
                        ),
                      ],
                      if (!isLoading) ...[
                        const SizedBox(height: 4),
                        ElevatedButton(
                          onPressed: () {
                            //_showSnackbar('settings', 2);
                            context.push('/login/settings'); // login
                          },
                          child: Row(
                            children: const [
                              Icon(
                                Icons.settings_outlined,
                                //size: 32,
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              Text('Настройки'),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
