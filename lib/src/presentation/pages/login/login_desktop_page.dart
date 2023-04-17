import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:tinycolor2/tinycolor2.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../secret.dart';
import '../../../services/oauth/oauth_service.dart';
import '../../../services/secure_storage/secure_storage_service.dart';
import '../../../utils/extensions/buildcontext.dart';

import 'disclaimer_dialog.dart';

Future<void> _launchUrl() async {
  if (!await launchUrl(Uri.parse(
      'https://shikimori.me/oauth/authorize?client_id=$kShikiClientIdDesktop&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&response_type=code&scope=user_rates'))) {
    // throw Exception('Could not launch $_url');
    throw Exception('Could not launch url');
  }
}

class LoginDesktopPage extends StatefulWidget {
  const LoginDesktopPage({super.key});

  @override
  State<LoginDesktopPage> createState() => _LoginDesktopPageState();
}

class _LoginDesktopPageState extends State<LoginDesktopPage> {
  bool showSplash = true;
  bool isLoading = false;
  bool showInput = false;

  late TextEditingController _controller;

  void _showSnackbar(String msg, int dur) {
    final snackBar = SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      dismissDirection: DismissDirection.horizontal,
      duration: Duration(seconds: dur),
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void goToHome() {
    GoRouter.of(context).go('/library'); //library explore
  }

  Future<void> auth(String code) async {
    setState(() {
      isLoading = true;
    });

    try {
      bool getTokenResult = await OAuthService.instance.getToken(code);

      if (getTokenResult) {
        goToHome();
      } else {
        _controller.clear();
        setState(() {
          isLoading = false;
          showInput = false;
        });
        _showSnackbar('Ошибка авторизации', 3);
      }
    } catch (e) {
      final expString = e.toString();
      _controller.clear();
      setState(() {
        isLoading = false;
        showInput = false;
      });
      _showSnackbar('Ошибка авторизации ($expString)', 3);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    if (SecureStorageService.instance.token != '') {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        goToHome();
      });
    } else {
      setState(() {
        showSplash = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: Center(
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
                      Text('Привет!',
                          style: Theme.of(context).textTheme.headlineLarge),
                      const SizedBox(height: 8),
                      Text(
                        'Для использования приложения\nнеобходимо войти в аккаунт Shikimori',
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
                      if (!isLoading && !showInput) ...[
                        ElevatedButton(
                          onPressed: () async {
                            bool? dialogValue = await showDialog<bool>(
                              context: context,
                              builder: (context) => const DisclaimerDialog(),
                            );
                            if (dialogValue ?? false) {
                              await _launchUrl();
                              setState(() {
                                showInput = true;
                              });
                              //return;
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.login_outlined,
                                  //size: 32,
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                Text('Войти с помощью браузера'),
                              ],
                            ),
                          ),
                        ),
                      ],

                      if (!isLoading && showInput) ...[
                        TextField(
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            hintText: 'Код авторизации',
                          ),
                          obscureText: true,
                          autocorrect: false,
                          controller: _controller,
                          onSubmitted: (value) async {
                            await auth(value);
                          },
                        ),
                      ],

                      // const SizedBox(
                      //   height: 8,
                      // ),
                      // if (!isLoading) ...[
                      //   const SizedBox(height: 4),
                      //   ElevatedButton(
                      //     onPressed: () {
                      //       context.push('/login/settings'); // login
                      //     },
                      //     child: Padding(
                      //       padding: const EdgeInsets.all(8.0),
                      //       child: Row(
                      //         children: const [
                      //           Icon(
                      //             Icons.settings_outlined,
                      //             //size: 32,
                      //           ),
                      //           SizedBox(
                      //             width: 12,
                      //           ),
                      //           Text('Настройки'),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ],
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
